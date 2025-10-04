#!/bin/bash
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting Flask setup..."

# Update system
apt update -y
apt install -y python3 python3-pip git

# Switch to ubuntu user
sudo -i -u ubuntu bash <<'EOF'
cd /home/ubuntu

# Clone repo if not exists, else pull updates
if [ ! -d "terraform" ]; then
  git clone https://github.com/yojana08/terraform.git
else
  cd terraform && git pull && cd ..
fi

cd terraform/backend

# Install dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
  pip3 install -r requirements.txt
else
  echo "⚠️ No requirements.txt found, installing Flask manually"
  pip3 install flask flask-cors
fi

# Run your backend (adjust entry file if different)
nohup python3 app.py > flask.log 2>&1 &

EOF

echo "✅ Flask setup complete"
