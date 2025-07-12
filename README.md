# FIAP Lumiere Infrastructure

This Terraform configuration creates a complete infrastructure for the FIAP Lumiere application, including both API backend and React frontend services running on AWS ECS with Fargate.

## Architecture Overview

The infrastructure includes:

### Load Balancer & Routing
- **Application Load Balancer (ALB)** - Routes traffic between frontend and API services
- **Network Load Balancer (NLB)** - Provides integration with API Gateway
- **Path-based routing**:
  - `/api/*` and `/docs/*` → API backend service (port 3000)
  - All other routes → React frontend service (port 80)

### ECS Services
- **API Backend Service** - Runs the application API (containerized on port 3000)
- **React Frontend Service** - Serves the React application (containerized on port 80)
- Both services run on AWS Fargate with auto-scaling capabilities

### Security
- Security groups with least-privilege access
- SSL/TLS support with self-signed certificates
- VPC endpoints for secure AWS service communication

### Monitoring & Logging
- CloudWatch log groups for both services
- Container Insights enabled for enhanced monitoring
- Health checks configured for both target groups

## Configuration

### Key Variables
- `desired_count` - Number of tasks to run (default: 0 for cost optimization)
- `domain_name` - Optional domain for SSL certificate
- `enable_custom_domain` - Enable Route53 custom domain support
- `enable_vpc_endpoints` - Enable VPC endpoints for better performance

### Container Configuration
- **API Container**: Uses nginx:latest (replace with your API image)
- **Frontend Container**: Uses nginx:alpine (replace with your React app image)
- Both containers configured with appropriate resource allocation (256 CPU, 512 MB memory)

## Deployment Notes

1. **Container Images**: Update the container images in the task definitions to use your actual application images
2. **Environment Variables**: The frontend container includes `REACT_APP_API_URL=/api` for API communication
3. **Health Checks**: API health check uses `/docs/` endpoint, frontend uses `/` endpoint
4. **Scaling**: Both services use the same `desired_count` variable for consistency

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Access the application
# Frontend: http://<alb-dns-name>/
# API docs: http://<alb-dns-name>/docs/
```

## Outputs

The module provides outputs for:
- Load balancer DNS names
- ECS service names and container names
- Target group ARNs
- Security group IDs
- SSL certificate information (if enabled)