import http from 'k6/http';
import { check } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
    scenarios: {
        spike_test: {
            executor: 'ramping-vus',
            startVUs: 0,
            stages: [
                { duration: '5s', target: 1000 },
                { duration: '5s', target: 0 },
            ],
            gracefulRampDown: '10s',
        },
    },
    thresholds: {
        'errors': ['rate<=0'],
        'http_req_duration': ['p(90)<3500'],
    },
};

const BASE_URL = 'http://acc-alb-825522962.ap-northeast-2.elb.amazonaws.com';

export default function () {
    const payload = JSON.stringify({
        productId: 1,
        quantity: 1,
    });

    const params = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    const res = http.post(`${BASE_URL}/api/v1/stocks/decrease`, payload, params);

    const success = check(res, {
        'status is 204': (r) => r.status === 204,
    });
    errorRate.add(!success);
}
