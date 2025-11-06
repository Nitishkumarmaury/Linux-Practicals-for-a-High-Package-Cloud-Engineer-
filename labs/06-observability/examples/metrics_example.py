# Example Application Instrumentation
from prometheus_client import Counter, Histogram, start_http_server
import random
import time

# Define metrics
REQUEST_COUNT = Counter('app_request_count_total', 'Total app requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('app_request_latency_seconds', 'Request latency', ['endpoint'])

def process_request(endpoint):
    # Start timing
    with REQUEST_LATENCY.labels(endpoint).time():
        # Simulate processing
        time.sleep(random.random())
        
        # Record the request
        status = '200' if random.random() > 0.1 else '500'
        REQUEST_COUNT.labels(method='GET', endpoint=endpoint, status=status).inc()

def main():
    # Start metrics server
    start_http_server(8000)
    
    # Simulate requests
    while True:
        process_request('/api/users')
        process_request('/api/orders')
        time.sleep(1)

if __name__ == '__main__':
    main()