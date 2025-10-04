#!/bin/bash
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting Express frontend setup..."

# Update system and install essentials
apt update -y
apt install -y git curl build-essential

# Install Node.js (v18 LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Switch to ubuntu user
sudo -i -u ubuntu bash <<'EOF'
cd /home/ubuntu

# Clone repo if not exists, else pull updates
if [ ! -d "terraform" ]; then
  git clone https://github.com/yojana08/terraform.git
else
  cd terraform && git pull && cd ..
fi

cd terraform/frontend

# Install frontend dependencies
npm install

# Set environment variables for Express
export BACKEND_URL="http://${flask_private_ip}:${flask_port}/api"
export EXPRESS_PORT="${express_port}"

echo "Starting Express with BACKEND_URL=$BACKEND_URL on port $EXPRESS_PORT ..."
nohup npm start > frontend.log 2>&1 &

sleep 5
echo "Express started. Checking if running..."
ps aux | grep node

EOF

echo "✅ Express frontend setup complete"
