@echo off
echo 🔄 Rebuilding and restarting backend container...
docker-compose up --build -d backend
echo ✅ Backend rebuilt and restarted!