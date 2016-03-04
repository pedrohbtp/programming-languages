from twisted.internet import reactor, protocol, endpoints
from twisted.protocols import basic
import logging
import logging.handlers
import herd_helpers as hhelp
import time
import decimal
from datetime import datetime
import config


class HerdProtocol(basic.LineReceiver):
    def __init__(self, factory):
        self.factory = factory

    def connectionMade(self):
        #self.factory.clients.add(self)
        self.factory.log('Connection Made')
        return True

    def connectionLost(self, reason):
        #self.factory.clients.remove(self)
        self.factory.log('Connection Lost')
        return True

    def lineReceived(self, line):
        self.factory.log('Line received: '+line)
        
        #Parses and stores the message
        flds = hhelp.parse_m(line)
        if flds == None or (not hhelp.valid_iamat(flds) and not hhelp.valid_whatsat(flds) and flds[0]!='AT'):
            #Invalid message send '? message' back to the user
            self.transport.write('? '+line+'\n')
            self.factory.log('Invalid command '+line)
        elif flds[0]=='AT':
            print(flds)
            #TODO: fix number rounding to make flooding work
            self.procAT(flds)
        elif flds[0]=='WHATSAT':
            if not self.factory.clients.has_key(flds[1]):
               self.transport.write('? '+line+'\n') 
               self.factory.log('Invalid WHATSAT command-No previous data for client: '+line)
            else:
                self.procWHATSAT(flds)
                self.factory.log('Successful WHATSAT answer')
        elif flds[0]=='IAMAT':
            self.procIAMAT(flds)
     
    def procAT(self,flds):
        # Tests if we have this message stored. If not, add and flood
        # flds[3] is client's name
        
        if  not self.factory.clients.has_key(flds[3]) or flds != hhelp.parse_m(self.at(flds[3])):
            # add to the cache
            self.factory.clients[flds[3]] = {
            'delay':flds[2],
            'lat': flds[4],
            'long': flds[5],
            'time': flds[6],
            'server':flds[1]
            }
            print(len(flds))
            #print(self.factory.clients.has_key(flds[3]))
            print(flds)
            print(hhelp.parse_m(self.at(flds[3])))
            self.flood(self.at(flds[3]))
            
            
    def procWHATSAT(self,flds):
        # flds[1] is client's name
        latest_at = self.at(flds[1])
        at_flds = hhelp.parse_m(latest_at)
        # Writes the most recent info about that client
        res_limit=flds[3]
        lat = at_flds[4]
        lng=at_flds[5]
        radius=flds[2]
        # print("lat:"+str(lat)+' long:'+str(lng))
        # print('radius:'+str(radius))
        json_res=hhelp.GoogPlac(lat,lng,radius,res_limit)
        self.transport.write(latest_at+'\n')
        self.transport.write(json_res+'\n\n')
        
        
    def procIAMAT(self,flds):
        # flds[1] is client's name
        # flds[4] is client's time
        # flds[2] is lat
        #flds[3] is long
        # Sets the precision of decimal to 9
        decimal.getcontext.prec=9
        now = "%.9f" %time.time()
        self.factory.clients[flds[1]] = {
            'delay':decimal.Decimal(now)-flds[4],
            'lat': flds[2],
            'long': flds[3],
            'time': flds[4],
            'server': self.factory.server_name
            }
        # repond with at command
        at_response = self.at(flds[1])
        self.transport.write(at_response+'\n')
        self.flood(at_response)
        self.factory.log("Flooded: "+at_response)
        
        
    # generates an AT command based on a client
    def at(self, client_name):
        client = self.factory.clients[client_name]
        return 'AT'+' '+client['server']+' '+hhelp.plus_min(client['delay'])+' '+client_name+' '+hhelp.plus_min(client['lat'])+hhelp.plus_min(client['long'])+' '+str(client['time'])
    
    #Sends data to all the ones you can talk to
    def flood(self, line):
        for neighbor_name in config.SERVERS[self.factory.server_name]['talks']:
            reactor.connectTCP('localhost', config.SERVERS[neighbor_name]["port"], HerdClientFactory(line))
            self.factory.log("Sending to "+neighbor_name+":"+line)
            
# Sever factory defining attributes
class HerdServerFactory(protocol.Factory):
    def __init__(self,server_name):
        #self.clients = set()
        self.server_name = server_name
        self.logger = logging.getLogger(self.server_name)
        # value is another dictionary with {cname: {'delay':, 'lat':, 'long':, 'time':}
        self.clients = dict()
        # sets up logging
        logging.basicConfig( level=logging.DEBUG, filemode='w')
        handler = logging.handlers.TimedRotatingFileHandler(filename='./logs/'+self.server_name+'.log')
        self.logger.addHandler(handler)
        self.log( "created")
        

    def buildProtocol(self, addr):
        return HerdProtocol(self)


    def log(self, mes):
        if mes !=None:
            self.logger.debug(str(datetime.utcnow())+ ' '+self.server_name+':'+mes)


# Client class. Used to make server talk to server
class HerdClient(basic.LineReceiver):
    def __init__ (self, line):
        self.line = line

    def connectionMade(self):
        self.sendLine(self.line)
        self.transport.loseConnection()

class HerdClientFactory(protocol.ClientFactory):
    def __init__(self, line):
        self.line = line

    def buildProtocol(self, addr):
        return HerdClient(self.line)



def main():
    # runs all SERVERS 
    for server in config.SERVERS.keys():
        #endpoints.serverFromString(reactor, "tcp:"+str(SERVERS[server]['port'])).listen(HerdServerFactory(server))
        reactor.listenTCP( config.SERVERS[server]['port'], HerdServerFactory(server))
    reactor.run()

if '__main__' == __name__:
    main()