@echo off
echo 🔄 Rebuilding and restarting frontend container...
docker-compose up --build -d frontend
echo ✅ Frontend rebuilt and restarted!