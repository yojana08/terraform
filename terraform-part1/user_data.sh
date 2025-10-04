#!/bin/bash
# Log everything for debugging
exec > >(tee /var/log/user-data.log)
exec 2>&1

# ----------------------------
# Update and install dependencies
# ----------------------------
apt update -y
apt upgrade -y
apt install -y python3 python3-pip git curl build-essential

# Install Node.js 16
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt install -y nodejs

# ----------------------------
# Switch to ubuntu user
# ----------------------------
sudo -i -u ubuntu bash <<'EOF'

cd /home/ubuntu

# Clone the latest Terraform repo
if [ ! -d "terraform" ]; then
    git clone https://github.com/yojana08/terraform.git
else
    cd terraform
    git reset --hard
    git pull
    cd /home/ubuntu
fi

cd terraform  # adjust this path if backend/frontend are elsewhere

# ===== Flask Backend =====
echo "Setting up Flask backend..."
cd backend
pip3 install flask
# pip3 install -r requirements.txt  # uncomment if you have requirements.txt

export FLASK_PORT=5000
nohup python3 app.py > flask.log 2>&1 &
echo "Flask started, waiting for startup..."
sleep 5  # wait for Flask to start

# ===== Express Frontend =====
echo "Setting up Express frontend..."
cd ../frontend
npm install

export BACKEND_URL="http://127.0.0.1:5000/api"
export EXPRESS_PORT=3000
nohup node app.js > express.log 2>&1 &
echo "Express started"

echo "Setup completed!"
echo "Flask logs: /home/ubuntu/terraform/backend/flask.log"
echo "Express logs: /home/ubuntu/terraform/frontend/express.log"

EOF