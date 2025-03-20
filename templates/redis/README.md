# Base Template

## About
---
### Redis
- Has a redis server running without auth at **port 6379**
- Example code snippet to connect using redis-py
```python
import redis

# Connect to Redis
r = redis.Redis(host='localhost', port=6379, decode_responses=True)

# Test if Redis is responding
print("PING:", r.ping())
```
---
### Environment
- Ubuntu based
- Home directory **/home/coder**
- Only the home directory is Persistent
- Any installations and files outside home will be reset on workspace restart
---
### Resources

| Resource       | Value |
| -------------- | ----- |
| Home Disk Size | 2GB   |
| CPU            | ~     |
| Memory         | 16GB  |

---
> #### Note
> - Any files outside of the home directory will be reset on workspace restarts
> - Deleting a workspace will also delete the **Home Directory !**
