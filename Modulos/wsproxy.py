#!/usr/bin/env python3
# encoding: utf-8
import socket, threading, thread, select, signal, sys, time, getopt, os

# Default configuration
PASS = ''
LISTENING_ADDR = '0.0.0.0'
try:
   LISTENING_PORT = int(sys.argv[1])
except:
   LISTENING_PORT = 80
BUFLEN = 8192 * 4
TIMEOUT = 60
MSG = 'DRAGON VPS MANAGER'
COR = '<font color="green">'
FTAG = '</font>'
DEFAULT_HOST = "127.0.0.1:22"
RESPONSE = "HTTP/1.1 101 " + str(COR) + str(MSG) + str(FTAG) + "\r\n\r\n"

# Check Python version
if sys.version_info[0] < 3:
    import thread
else:
    import _thread as thread

# Signal handler for clean exit
def signal_handler(sig, frame):
    print('\nShutting down...')
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

class Server(threading.Thread):
    def __init__(self, host, port):
        threading.Thread.__init__(self)
        self.running = False
        self.host = host
        self.port = port
        self.threads = []
        self.threadsLock = threading.Lock()
        self.logLock = threading.Lock()

    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2)
        
        try:
            self.soc.bind((self.host, self.port))
            self.soc.listen(0)
            self.running = True
            self.printLog(f"WebSocket Proxy running on {self.host}:{self.port}")
        except Exception as e:
            self.printLog(f"Error binding to {self.host}:{self.port}: {str(e)}")
            self.running = False
            return

        try:                    
            while self.running:
                try:
                    c, addr = self.soc.accept()
                    c.setblocking(1)
                    self.printLog(f"Connection from {addr[0]}:{addr[1]}")
                except socket.timeout:
                    continue
                except Exception as e:
                    self.printLog(f"Error accepting connection: {str(e)}")
                    continue
                
                conn = ConnectionHandler(c, self, addr)
                conn.start();
                self.addConn(conn)
        finally:
            self.running = False
            self.soc.close()
            
    def printLog(self, log):
        self.logLock.acquire()
        print(log)
        self.logLock.release()
    
    def addConn(self, conn):
        try:
            self.threadsLock.acquire()
            if self.running:
                self.threads.append(conn)
        finally:
            self.threadsLock.release()
                    
    def removeConn(self, conn):
        try:
            self.threadsLock.acquire()
            self.threads.remove(conn)
        finally:
            self.threadsLock.release()
                
    def close(self):
        try:
            self.running = False
            self.threadsLock.acquire()
            
            threads = list(self.threads)
            for c in threads:
                c.close()
        finally:
            self.threadsLock.release()
            

class ConnectionHandler(threading.Thread):
    def __init__(self, socClient, server, addr):
        threading.Thread.__init__(self)
        self.clientClosed = False
        self.targetClosed = True
        self.client = socClient
        self.client_buffer = ''
        self.server = server
        self.addr = addr
        self.log = f'Connection: {addr[0]}:{addr[1]}'

    def close(self):
        try:
            if not self.clientClosed:
                self.client.shutdown(socket.SHUT_RDWR)
                self.client.close()
        except:
            pass
        finally:
            self.clientClosed = True
            
        try:
            if not self.targetClosed:
                self.target.shutdown(socket.SHUT_RDWR)
                self.target.close()
        except:
            pass
        finally:
            self.targetClosed = True

    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN).decode()
        except Exception as e:
            self.log += f' - Error receiving data: {str(e)}'
            self.server.printLog(self.log)
            self.close()
            return
        
        try:
            hostPort = self.findHeader(self.client_buffer, 'X-Real-Host')
            
            if hostPort == '':
                hostPort = DEFAULT_HOST

            split = self.findHeader(self.client_buffer, 'X-Split')

            if split != '':
                self.client.recv(BUFLEN)
            
            if hostPort != '':
                passwd = self.findHeader(self.client_buffer, 'X-Pass')
                
                if len(PASS) != 0 and passwd == PASS:
                    self.method_CONNECT(hostPort)
                elif len(PASS) != 0 and passwd != PASS:
                    self.client.send('HTTP/1.1 400 WrongPass!\r\n\r\n'.encode())
                    self.server.printLog(f'{self.addr[0]}:{self.addr[1]} - Wrong password')
                elif hostPort.startswith('127.0.0.1') or hostPort.startswith('localhost'):
                    self.method_CONNECT(hostPort)
                else:
                    self.client.send('HTTP/1.1 403 Forbidden!\r\n\r\n'.encode())
                    self.server.printLog(f'{self.addr[0]}:{self.addr[1]} - Forbidden host: {hostPort}')
            else:
                self.server.printLog(f'{self.addr[0]}:{self.addr[1]} - No X-Real-Host!')
                self.client.send('HTTP/1.1 400 NoXRealHost!\r\n\r\n'.encode())

        except Exception as e:
            self.log += f' - Error: {str(e)}'
            self.server.printLog(self.log)
        finally:
            self.close()
            self.server.removeConn(self)

    def findHeader(self, head, header):
        aux = head.find(header + ': ')
    
        if aux == -1:
            return ''

        aux = head.find(':', aux)
        head = head[aux+2:]
        aux = head.find('\r\n')

        if aux == -1:
            return ''

        return head[:aux];

    def connect_target(self, host):
        i = host.find(':')
        if i != -1:
            port = int(host[i+1:])
            host = host[:i]
        else:
            if self.method=='CONNECT':
                port = 443
            else:
                port = 80

        try:
            (soc_family, soc_type, proto, _, address) = socket.getaddrinfo(host, port)[0]
            self.target = socket.socket(soc_family, soc_type, proto)
            self.targetClosed = False
            self.target.connect(address)
            return True
        except Exception as e:
            self.log += f' - Error connecting to target {host}:{port}: {str(e)}'
            self.server.printLog(self.log)
            return False

    def method_CONNECT(self, path):
        self.log += f' - CONNECT {path}'
        
        if not self.connect_target(path):
            self.client.send('HTTP/1.1 502 Bad Gateway\r\n\r\n'.encode())
            return
            
        self.client.sendall(RESPONSE.encode())
        self.client_buffer = ''

        self.server.printLog(self.log)
        self.doCONNECT()

    def doCONNECT(self):
        socs = [self.client, self.target]
        count = 0
        error = False
        while True:
            count += 1
            (recv, _, err) = select.select(socs, [], socs, 3)
            if err:
                error = True
            if recv:
                for in_ in recv:
                    try:
                        data = in_.recv(BUFLEN)
                        if data:
                            if in_ is self.target:
                                self.client.send(data)
                            else:
                                while data:
                                    byte = self.target.send(data)
                                    data = data[byte:]

                            count = 0
                        else:
                            break
                    except Exception as e:
                        self.log += f' - Error in data transfer: {str(e)}'
                        error = True
                        break
            if count == TIMEOUT:
                error = True

            if error:
                break


def print_usage():
    print('Usage: wsproxy.py -p <port>')
    print('       wsproxy.py -b <ip> -p <port>')
    print('       wsproxy.py -b 0.0.0.0 -p 80')

def parse_args(argv):
    global LISTENING_ADDR
    global LISTENING_PORT
    
    try:
        opts, args = getopt.getopt(argv,"hb:p:",["bind=","port="])
    except getopt.GetoptError:
        print_usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print_usage()
            sys.exit()
        elif opt in ("-b", "--bind"):
            LISTENING_ADDR = arg
        elif opt in ("-p", "--port"):
            LISTENING_PORT = int(arg)
    

def main(host=LISTENING_ADDR, port=LISTENING_PORT):
    print("\n ==============================")
    print(" DRAGON VPS MANAGER WEBSOCKET")
    print(" ==============================\n")
    print(f" * Running on {host}:{port}")
    
    server = Server(host, port)
    server.start()
    
    while True:
        try:
            time.sleep(2)
        except KeyboardInterrupt:
            print('\nShutting down...')
            server.close()
            sys.exit(0)
            
if __name__ == '__main__':
    parse_args(sys.argv[1:])
    main()
