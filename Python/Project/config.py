# File containing the configurations for the servers
# Please put your Google API Key in GOOGLE_KEY
# Change the TCP ports of the servers as desired

GOOGLE_KEY="AIzaSyC0orE6ZmGGzQ-oqD930R3Dx-FSKhgm1Rg"

SERVERS = {
    
	'Bolden': {'port':1235, 'talks': ['Welsh','Parker']},
	'Alford': {'port':1234 , 'talks': ['Welsh','Parker']},
	'Hamilton': {'port':1236, 'talks': ['Parker']},
	'Parker': {'port':1237, 'talks': ['Bolden', 'Alford', 'Hamilton']},
	'Welsh': {'port':1238,'talks':['Bolden']}
	}