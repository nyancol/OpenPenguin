To start a test, start a virtual environment and download packages:

```
pip install --user virtualenv
virtualenv venv -p python3
source venv/bin/activate
pip install flask
pip install requests
pip install pika
pip install python-swiftclient
pip install redis

```

Then start a test:

```
python test_<module_name>.py
```
