package com.github.ywoosang.api.filter;

import java.io.IOException;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Order(Ordered.HIGHEST_PRECEDENCE)
@Component
public class MdcFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(MdcFilter.class);

    private static final String TRACE_ID = "traceId";

    private record HttpLogMessage(String method, String uri, int status, double elapsed) {

        public String toString() {
            return String.format("[HTTP] %s %s %d (%.3f sec)", method, uri, status, elapsed);
        }

        public static HttpLogMessage of(HttpServletRequest request, HttpServletResponse response, double elapsed) {
            return new HttpLogMessage(
                request.getMethod(),
                request.getRequestURI(),
                response.getStatus(),
                elapsed
            );
        }
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
        throws ServletException, IOException {

        ContentCachingRequestWrapper requestWrapper = new ContentCachingRequestWrapper(request);
        ContentCachingResponseWrapper responseWrapper = new ContentCachingResponseWrapper(response);

        String traceId = UUID.randomUUID()
            .toString()
            .substring(0, 8);

        MDC.put(TRACE_ID, traceId);

        long start = System.currentTimeMillis();
        try {
            filterChain.doFilter(requestWrapper, responseWrapper);

            double elapsed = (System.currentTimeMillis() - start) / 1000.0;
            HttpLogMessage logMessage = HttpLogMessage.of(requestWrapper, responseWrapper, elapsed);
            log.info(logMessage.toString());

        } catch (Exception e) {
            log.error("Request logging failed", e);
            throw e;
        } finally {
            MDC.remove(TRACE_ID);
            responseWrapper.copyBodyToResponse();
        }
    }
}