import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  scenarios: {
    spike_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5s', target: 1000 },  // 5초 동안 1000명으로 증가
        { duration: '5s', target: 0 },     // 5초 동안 0명으로 감소
      ],
      gracefulRampDown: '10s',
    },
  },
  thresholds: {
    'errors': ['rate<0.2'],  // 에러율 20% 미만
    'http_req_duration': ['p(95)<3000'],  // 95%의 요청이 3초 이내 처리
    'http_req_failed': ['rate<0.2'],  // 실패율 20% 미만
  },
};

const BASE_URL = 'http://localhost:8080';

export default function () {
  const payload = JSON.stringify({
    productId: 1,
    quantity: 1
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  // V1 엔드포인트 테스트
  const v1Response = http.post(
    `${BASE_URL}/api/v1/stocks/decrease`,
    payload,
    params
  );
  check(v1Response, {
    'V1 status is 204': (r) => r.status === 204,
    'V1 response time < 3000ms': (r) => r.timings.duration < 3000,
  }) || errorRate.add(1);
} 