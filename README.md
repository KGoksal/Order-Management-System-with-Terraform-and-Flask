# Order Management System Webserver with Terraform and Flask

This project showcases a straightforward Order Management System using Terraform for infrastructure setup, Flask for backend API development, and HTML for frontend presentation.

## Flask Application (`order-table.py`)
The Flask application (`order-table.py`) serves as the backend API to manage orders:

### MySQL Configuration
Connects to an RDS MySQL database (`order_table`) to store order information.

### Routes
- `/`: Displays existing orders in a tabular format.
- `/add_order`: Accepts form submissions to add new orders to the database.

### Key Functionalities
- **Initialization of Database**: Automatically creates the `orders` table if it doesn't exist.
- **Functions**:
  - `get_orders()`: Retrieves all orders from the database.
  - `add_order()`: Inserts a new order into the database.
For detailed Flask application code, refer to `order-table.py`.

## HTML Frontend (`index.html`)
The HTML file (`index.html`) provides a user interface to interact with the Flask application:

### Features
- **Displays Orders**: Shows existing orders in a table format.
- **Adds New Orders**: Contains a form to input customer name, status, progress, order date, and country.
For detailed HTML code, refer to `index.html`.

## Getting Started
### Prerequisites

Before running the project, ensure you have:
- **AWS Account**: Configure AWS credentials with sufficient permissions for Terraform.
- **Python 3**: Install necessary Python packages using `pip install -r requirements.txt`.

## Terraform Infrastructure Deployment Overview
This project leverages Terraform to provision and manage essential infrastructure components on AWS for an Order Management System. Here's an overview of what is configured and deployed through the Terraform files (`main.tf`):

### AWS Resources Deployed
1. **Virtual Private Cloud (VPC)**
   - **Purpose**: Provides an isolated network environment for application resources.
   - **Components**:
     - VPC: Main networking container for AWS resources.
     - Subnets: Divided into public and private subnets across multiple Availability Zones (AZs) for high availability.
     - Internet Gateway (IGW): Allows communication between the VPC and the internet.

2. **Security Groups**
   - **Purpose**: Acts as virtual firewalls for EC2 instances and the RDS database.
   - **Configuration**:
     - Application Load Balancer (ALB) Security Group: Allows inbound traffic on port 80 from the internet.
     - Database Security Group (DB SG): Restricts database access to specified IP addresses.

3. **RDS (MySQL) Instance**
   - **Purpose**: Managed relational database service for storing order data.
   - **Configuration**:
     - Instance Class: `db.t3.micro` for low-cost testing and development.
     - Allocated Storage: 20 GB with automatic storage scaling.
     - Engine Version: MySQL 8.0.28.
     - Multi-AZ Deployment: Disabled for cost optimization.
     - Public Accessibility: Disabled for security (accessed via VPC).

4. **Application Load Balancer (ALB) and Target Group**
   - **Purpose**: Distributes incoming HTTP traffic across multiple EC2 instances.
   - **Configuration**:
     - Load Balancer Type: Application Load Balancer for flexible routing.
     - Listeners: Configured on port 80 for HTTP traffic.
     - Target Group: Directs traffic to EC2 instances based on health checks.

5. **EC2 Instances**
   - **Purpose**: Hosts the Flask application managing orders.
   - **Configuration**:
     - Instance Type: Typically `t2.micro` for cost-effective testing.
     - AMI: Based on a predefined Amazon Machine Image suitable for Python applications.
     - Security Group: Ensures instances have appropriate network access.

### Outputs
- **Website URL**: Provides the URL to access the application via Route 53 or ALB DNS name.
- **Database Address and Endpoint**: Offers connectivity details for accessing the MySQL database.

## SUMMARY
Using Terraform, we successfully deployed an Order Management System (OMS) infrastructure on AWS. This setup included a Virtual Private Cloud (VPC) with public and private subnets across multiple Availability Zones, ensuring high availability and secure networking. We provisioned an Application Load Balancer (ALB) to distribute HTTP traffic to Flask-based EC2 instances hosting the OMS application. Additionally, a MySQL RDS instance was deployed to securely store order data. Security groups were configured to control traffic, and IAM roles were defined for secure access management. If Route 53 is not available, the web server can be accessed via the ALB's DNS name, providing reliable and scalable access to the application.

![Security-Groups](https://github.com/user-attachments/assets/5afa4632-9347-4be0-9d4b-1dbcc82b1669)
<img width="818" alt="Screenshot 2024-07-11 at 4 15 42 PM" src="https://github.com/user-attachments/assets/d8547d0e-5891-4b18-a1d3-ecb77b28eb92">

