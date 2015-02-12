DIRECTIONS = {
	up: {x: 0, y: 1},
	down: {x: 0, y: -1},
	left: {x: -1, y: 0},
	right: {x: 1, y: 0}
}

SPEED = {
	:quick => 1,
	:slow => 3,
}

DISTANCE = {
	:short => 50,
	:long => 200,
}


FIRSTRESPONDERSUPPORTED = [
	'textField', 
  'textView', 
  'TextViewControl',
  'TextFieldControl',
  'ComboBoxFieldControl', 
  'TimePickerFieldControl',
  'DatePickerFieldControl',
]

LOCATIONS = {
	westminsterCoord: {
		latitude: 51.5010,
    longitude: -0.1250,
   },
	westminsterCoord: {
		place: 'Westminster tube station',
	},   
  northGreenwich: {
  	latitude: 51.500,
    longitude: 0.0036
   	#place: 'North Greenwich tube station',
  },
  picadillyCircus: {
   	place: 'Picadilly Circus tube station',
  },
  oxfordCircus: {
  	latitude: 51.515,
    longitude: -0.140
  }
}