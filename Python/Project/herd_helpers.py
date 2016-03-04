import re
import urllib, json
import decimal
import config

message_types = {
        'AT': {'f_types':[str,str,decimal.Decimal,str,decimal.Decimal,decimal.Decimal,decimal.Decimal], 'reg':'^[\s]*([a-zA-Z]+)[\s]+([^\s\t\n\v\f\r]+)[\s]+([+|-][0-9]+[.][0-9]+)([+|-][0-9]+[.][0-9]+)[\s]+([0-9]+[.][0-9]+)[\s]*$' },
        'IAMAT': {'f_types':[str,str,decimal.Decimal,decimal.Decimal,decimal.Decimal], 'reg': '^[\s]*([a-zA-Z]+)[\s]+([^\s\t\n\v\f\r]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]*$'},
        'WHATSAT': {'f_types':[str,str,int,int], 'reg': '^[\s]*([a-zA-Z]+)[\s]+([a-zA-Z]+)[\s]+([+|-][0-9]+[.][0-9]+)[\s]+([^\s\t\n\v\f\r]+)[\s]+([+|-][0-9]+[.][0-9]+)([+|-][0-9]+[.][0-9]+)[\s]+([0-9]+[.][0-9]+)[\s]*$'}
        }

iamat = {
'client':None,
'lat':None,
'long':None,
'time':None

}
whatsat = {
'client':None,
'radius':None,
'items':None

}

at = {
'delay':None,
'client':None,
'lat':None,
'long':None,
'time':None

}


# To test: 
# GoogPlac(-33.8670, 151.1957, 500,1)
#Returns a string representing a Json object
def GoogPlac(lat,lng,radius,res_limit):
  #making the url
  LOCATION = str(lat) + "," + str(lng)
  RADIUS = radius
  MyUrl = ('https://maps.googleapis.com/maps/api/place/nearbysearch/json'
           '?location=%s'
           '&radius=%s'
           '&sensor=false&key=%s') % (LOCATION, RADIUS, config.GOOGLE_KEY)
#   print('LOCATION:'+LOCATION)
  #grabbing the JSON result
  response = urllib.urlopen(MyUrl)
  jsonRaw = response.read()
  #remove trailing \n  
  #jsonProc = re.sub("(\\n)+$", "",jsonRaw)  
  #Replaces two or more \n by a single one
  #jsonProc = re.sub("(\\n){2,}", "\n",jsonProc)      
  jsonData = json.loads(jsonRaw)
  #Filters the number of results
  if len(jsonData['results']) > res_limit:
        jsonData['results']=jsonData['results'][0:res_limit]
  jsonReturn = json.dumps(jsonData,indent=3)
    
  return jsonReturn


def plus_min(num):
    '''Receives a number. Returns a str with a + appended
    to the begining if it is positive
    '''
    if num<0:
        return str(num)
    else:
        return '+'+str(num)
    
    
    
def valid_whatsat(flds):
    '''Checks if a WHATSAT message is valid
    Receives a list representing the fields of the message.
    Each field should be in the correct type, otherwise 
    it has undefined behavior
    Returns true if valid, false if invalid
    '''
    #TODO: test it
    # flds[2]: radius between 0 and 50
    # flds[3]: number of items to return. Between 0 and 20
    #flds[2]: latidude. between -90 and 90
    #flds[3]: Longitude. Between -180 and 180
    if flds[0]!='WHATSAT' or len(flds)!=4 or flds[2]<=0 or flds[2]>50 or flds[3]>20 or  abs(flds[2])>90 or abs(flds[3])>180:
        return False
    else: 
        return True

def valid_iamat(flds):    
    '''Checks if a IAMAT message is valid
    Receives a list representing the fields of the message.
    Each field should be in the correct type, otherwise 
    it has undefined behavior
    Returns true if valid, false if invalid
    ''' 
    #TODO: test it
    #flds[2]: latidude. between -90 and 90
    #flds[3]: Longitude. Between -180 and 180
    if flds[0]!='IAMAT' or len(flds)!=5 or  abs(flds[2])>90 or abs(flds[3])>180:
        return False
    else:
        return True
    
    
def error_mes(m):
    ''' Prints an error message
    '''
    print("? "+m)
    # Aborts


def parse_m(mes):
    '''Parses the server message passed as mes
    Returns a list representing the fields of the message. Each field will already be converted to its type defined in message_types
    Ex: parse_m('IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1400794645.392014450')
    
    Ex:parse_m('AT Alford +0.563873386 kiwi.cs.ucla.edu +34.068930-118.445127 1400794699.108893381')
    
    Ex:parse_m('WHATSAT kiwi.cs.ucla.edu 10 5')
    '''
    
    # Tries all regular expressions specified in message_types
    for t in message_types.iteritems():
        res = re.search(t[1]['reg'], mes)
        if res != None:
            break
    # Checks if there was a match and it the command is valid
    if res == None or res.group(1) not in message_types.keys():
        #Raises an error. Malformated message
        #error_mes(mes)
        return None
    else:
        # Transforms the matches into a list of strings
        fld_str = list(res.groups())
        # Converts each field captured by the regular expression into its actual type
        # The type is defined into the message_types dictionary
        flds = [ty(val) for ty, val in zip(message_types[fld_str[0]]['f_types'], fld_str)]
        return flds
        
        
def num2str(num, precision): 
    return "%0.*f" % (precision, num) 
    