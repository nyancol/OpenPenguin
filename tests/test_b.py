#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://0.0.0.0:8082/
# curl -X POST http://0.0.0.0:8082/shutdown


import unittest
import sys
import threading
import time
import socket
import json
import requests

sys.path.append('/user/7/.base/cabrerap/home/Downloads/OpenPenguin/microservices/b')
import b

def print_header(text):
    print("\n####################")
    print(text)
    print("####################\n")


class ThreadingB(object):

    def __init__(self, interval=1):
        self.interval = interval
        thread = threading.Thread(target = self.run, args = ())
        thread.daemon = True
        thread.start()

    def run(self):
        b.start_service()

class ThreadingP(object):

    def __init__(self, interval=1):
        self.interval = interval
        thread = threading.Thread(target = self.run, args = ())
        thread.daemon = True
        thread.start()

    def run(self):
        p.start_service()


class TestServices(unittest.TestCase):
	
    def test_b(self):
        print_header("Testing b...")
        # Starting the service
        test = ThreadingB()
        time.sleep(2)
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        print("Testing if service is deployed ... ")
        self.assertTrue(sock.connect_ex(('0.0.0.0', 8082)) == 0)
        sock.close()
        print("Testing b.api_root() ...")
        resp = requests.get(url='http://0.0.0.0:8082/')
        data = json.loads(resp.text)
        self.assertTrue(data["Service"] == "Microservice b")
        # Testing b.shutdown
        time.sleep(2)


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(TestServices)
    unittest.TextTestRunner(verbosity=2).run(suite)


