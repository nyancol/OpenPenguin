#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Tests pour le lancement des microservices et les fonctions qui leur sont propres
# TODO: Ecrire des tests pour la communication entre services


import unittest
import sys
import threading
import time
import socket
import json
import requests
import os

sys.path.append('/user/7/.base/cabrerap/home/Downloads/OpenPenguin/microservices/b')
sys.path.append('/user/7/.base/cabrerap/home/Downloads/OpenPenguin/microservices/i')
sys.path.append('/user/7/.base/cabrerap/home/Downloads/OpenPenguin/microservices/p')
sys.path.append('/user/7/.base/cabrerap/home/Downloads/OpenPenguin/microservices/s')
sys.path.append('/user/7/.base/cabrerap/home/Downloads/OpenPenguin/microservices/w')
sys.path.append('/user/7/.base/cabrerap/home/Downloads/OpenPenguin/microservices/w1')
sys.path.append('/user/7/.base/cabrerap/home/Downloads/OpenPenguin/microservices/w2')

import b
# import i #Requires python-mysql
import p
import s
import w
# import w1
# import w2

def print_header(text):
    print("\n\n####################")
    print("\033[95m" + text + "\033[0m")
    print("####################\n")

def print_res(test):
    if test:
        print("\033[92m\t[PASSED]\033[0m")
    else:
        print("\033[91m\t[FAILED]\033[0m")


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


class ThreadingS(object):
    def __init__(self, interval=1):
        self.interval = interval
        thread = threading.Thread(target = self.run, args = ())
        thread.daemon = True
        thread.start()

    def run(self):
        s.start_service()


class ThreadingW(object):
    def __init__(self, interval=1):
        self.interval = interval
        thread = threading.Thread(target = self.run, args = ())
        thread.daemon = True
        thread.start()

    def run(self):
        w.start_service()


class TestServices(unittest.TestCase):

    def test_b(self):
        print_header("Testing b...")
        # Starting the service
        run = ThreadingB()
        time.sleep(2)
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        print("Testing if service is deployed ... ")
        test = bool(sock.connect_ex(('0.0.0.0', 8082)) == 0)
        sock.close()
        self.assertTrue(test, msg=test)
        print_res(test)
        print("Testing b.api_root() ...")
        resp = requests.get(url='http://0.0.0.0:8082/')
        data = json.loads(resp.text)
        test = bool(data["Service"] == "Microservice b")
        self.assertTrue(test, msg=test)
        print_res(test)
        print("Testing server shutdown...")
        resp = requests.post(url='http://0.0.0.0:8082/shutdown')
        test = bool(resp.text == "Server shutting down...")
        self.assertTrue(test, msg=test)
        print_res(test)
        time.sleep(2)

    def test_p(self):
        print_header("Testing p...")
        # Starting the service
        run = ThreadingP()
        time.sleep(2)
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        print("Testing if service is deployed ... ")
        test = bool(sock.connect_ex(('0.0.0.0', 8083)) == 0)
        sock.close()
        self.assertTrue(test, msg=test)
        print_res(test)
        print("Testing p.api_root() ...")
        resp = requests.get(url='http://0.0.0.0:8083/')
        data = json.loads(resp.text)
        test = bool(data["Service"] == "Microservice p")
        self.assertTrue(test, msg=test)
        print_res(test)
        print("Testing server shutdown...")
        resp = requests.post(url='http://0.0.0.0:8083/shutdown')
        test = bool(resp.text == "Server shutting down...")
        self.assertTrue(test, msg=test)
        print_res(test)
        time.sleep(2)

    def test_s(self):
        print_header("Testing s...")
        # Starting the service
        run = ThreadingS()
        time.sleep(2)
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        print("Testing if service is deployed ... ")
        test = bool(sock.connect_ex(('0.0.0.0', 8081)) == 0)
        sock.close()
        self.assertTrue(test, msg=test)
        print_res(test)
        print("Testing s.api_root() ...")
        resp = requests.get(url='http://0.0.0.0:8081/')
        data = json.loads(resp.text)
        test = bool(data["Service"] == "Microservice s")
        self.assertTrue(test, msg=test)
        print_res(test)
        print("Testing server shutdown...")
        resp = requests.post(url='http://0.0.0.0:8081/shutdown')
        test = bool(resp.text == "Server shutting down...")
        self.assertTrue(test, msg=test)
        print_res(test)
        time.sleep(2)

    def test_w(self):
        print_header("Testing w...")
        # Starting the service
        run = ThreadingW()
        time.sleep(2)
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        print("Testing if service is deployed ... ")
        test = bool(sock.connect_ex(('0.0.0.0', 8090)) == 0)
        sock.close()
        self.assertTrue(test, msg=test)
        print_res(test)
        print("Testing w.api_root() ...")
        resp = requests.get(url='http://0.0.0.0:8090/')
        data = json.loads(resp.text)
        test = bool(data["Service"] == "Microservice w")
        self.assertTrue(test, msg=test)
        print_res(test)
        print("Testing server shutdown...")
        resp = requests.post(url='http://0.0.0.0:8090/shutdown')
        test = bool(resp.text == "Server shutting down...")
        self.assertTrue(test, msg=test)
        print_res(test)
        time.sleep(2)


if __name__ == '__main__':
    unittest.main()


