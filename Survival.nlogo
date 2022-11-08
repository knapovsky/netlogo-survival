; Global variables
globals [
  babies-to-be-born
  max-babies-to-be-born
  mean-threshold-of-suitable-humans
  mean-energy-threshold
  mean-returning-home-factor
  humans-well-fed
  humans-hungry
  ]

; Patch properties
patches-own [
  nest?               
  food?               
  ]

; Human agent definition
breed[
  humans 
  human
  ]

; Wolf agent definition
breed[
  wolves 
  wolf
  ]

; Wolf agent properties
wolves-own [
  energy
  age
]

; Human agent properties
humans-own[
  energy
  energy-threshold
  age
  ; returning-home-factor
  ]

; Setup procedure - creates humans, wolves, food and nest
; -----------------------------------------------------------------------------
to setup
  
  clear-all
  
  ; Create humans
  ; ---------------------------------------------------------------------------
  set-default-shape humans "person"
  create-humans (max-number-of-humans / 2)
  [ 
    set size 1
    ; Starting as hungry
    set color blue
    ; Starting at home
    setxy 0 0
    ; Set initial energy to 3/4 of max-energy
    set energy ceiling( random-normal ((3 / 4) * max-human-energy) ((((1 / 4)) * max-human-energy)))
    ; Set energy threshold - everyone is the same
    set energy-threshold init-mean-energy-threshold
    ; Set age randomly - they are still young
    set age ceiling( random-normal ((1 / 2) * max-human-age) (((1 / 4)) * max-human-age))
    ; Default behaviour of humans - returning home
    ; set returning-home-factor 20
  ]
  ; ---------------------------------------------------------------------------
  
  ; Create wolves 
  ; ---------------------------------------------------------------------------
  set-default-shape wolves "wolf"
  
  ifelse wolf-dynamics [
    create-wolves (max-number-of-wolves / 2)[ 
      set size 1  
      set color brown
      ; Set initial energy to 3/4 of max-energy
      set energy ceiling(random-normal ((3 / 4) * max-wolf-energy) ((((1 / 4)) * max-wolf-energy)))
      ; place wolf randomly
      setxy random-xcor random-ycor
    ]
  ]
  [
    create-wolves max-number-of-wolves [
      set size 1
      set color brown
      setxy random-xcor random-ycor
    ]
  ]
  
  
  ; ---------------------------------------------------------------------------
  
  ; Create food 
  ; ---------------------------------------------------------------------------
  ; place food piles randomly
  ask n-of food-piles patches with [distancexy 0 0 > 5 and abs pxcor < (max-pxcor - 2) and abs pycor < (max-pycor - 2)][ 
    set pcolor green]
  ; ---------------------------------------------------------------------------
  
  ; Create human nest 
  ; ---------------------------------------------------------------------------
  ask patches
  [
    ; nest is in the middle 
    set nest? (distancexy 0 0) < 2
    if nest? [ set pcolor red ]
  ]
  ; ---------------------------------------------------------------------------
  
  ; Get wolves out of human nest before simulation
  ; ---------------------------------------------------------------------------
  ask wolves 
  [
    if nest? = true
    [
      setxy xcor + 4 ycor + 4
    ]
  ]
  ; ---------------------------------------------------------------------------
  
  reset-ticks
end

; Running simulation
; -----------------------------------------------------------------------------
to go
  
  ; When there are no humans, stop simulation
  if not any? humans [ stop ]
  
  ; Human behavior
  ; ---------------------------------------------------------------------------
  ask humans [
    
    ; Age is higher than maximal human age
    if age = max-human-age [
      die
    ]
    
    ; Lack of energy
    if energy < 0 [ 
      die
    ]
    
    ; Blue humans are looking for food, yellow are fine
    ifelse energy < energy-threshold [
      set color blue
    ]
    [
      set color yellow 
    ]
    
    ; Blue humans randomly looking for food out of nest
    ifelse color = blue
    [
      move 
    ]
    ; Yellow humans heading back to nest
    [
      ifelse wolf-dynamics [
        ;ifelse returning-home-factor > 40 [
        ;  move
        ;]
        ;[
          return-home  
        ;]
      ]
      [
        return-home
      ]  
    ]
    
    ; Food found - set energy to max
    if pcolor = green [
      set energy max-human-energy
    ]
    
    if(count(humans with [pcolor = red] with [color = yellow] with [age >= min-human-breeding-age]) >= 2) [
      ; Humans must be at home, well fed, they must be older than minimal breeding age
      ; Number of babies are divided by 2 - 2 people needed to have a baby
      set babies-to-be-born ( count(humans with [pcolor = red] with [color = yellow] with [age >= min-human-breeding-age]) / 2 )
      ; Food resources are limited, thus there is maximum number of babies that can be born
      set max-babies-to-be-born (max-number-of-humans - count(humans))
      if (babies-to-be-born > max-babies-to-be-born) [
        set babies-to-be-born max-babies-to-be-born
      ] 
      
      ; Get set of people with suitable factors, get their mean energy threshold a hatch new people (babies - age 0) with mutation factor
      set mean-threshold-of-suitable-humans ( mean([energy-threshold] of humans with [pcolor = red] with [color = yellow] with [age >= min-human-breeding-age]) )
      ;set mean-returning-home-factor ( mean([returning-home-factor] of humans with [pcolor = red] with [color = yellow] with [age >= min-human-breeding-age]) )
      hatch babies-to-be-born [
        set age 0
        set energy-threshold (random-normal (mean-threshold-of-suitable-humans) (mutation-factor))
        ; set returning-home-factor (random-normal (mean-returning-home-factor) (mutation-factor))
      ]
      
      ; Repair normal distribution
      ask humans with [energy-threshold < 0] [
        set energy-threshold 0
      ]
      ;ask humans with [returning-home-factor < 0] [
      ;  set returning-home-factor 0
      ;]
    ]
    
    ; Energy depletion
    set energy energy - 1
    
    ; Aging of humans
    set age age + 1
  ]
  ; ---------------------------------------------------------------------------
  
  ; Wolf behavior
  ; ---------------------------------------------------------------------------
  ask wolves [
    
    if wolf-dynamics [
      ; Wolf dies
      if energy < 0 [
        die
      ]
      if age >= max-wolf-age [
        die
      ]
      
      if energy > wolf-breed-energy-threshold [
        if (count (wolves) < max-number-of-wolves) [
          hatch 1 [
            set age 0
            set energy max-wolf-energy
          ]
        ]
      ]
    ]
    
    ; wolf and human on the same patch - wolf eats human
    ask humans-on patch-here [
      die
      
      if wolf-dynamics [
        set energy max-wolf-energy
      ]
    ]
    
    if wolf-dynamics [
      set energy energy - 1
    ]
    
    move-wolf
  ]
  
  ; Count human mean energy threshold
  if (count(humans) > 0) [
    set mean-energy-threshold mean([energy-threshold] of humans)
  ]
  
  ; Count hungry humans
  set humans-hungry (count(humans with [color = blue]))
  ; Count well-fed humans
  set humans-well-fed (count(humans with [color = yellow]))
  
  tick
end

to move 
  rt random 50
  lt random 50
  fd 1
end

to move-wolf
  ask wolves [
    ifelse [pcolor] of patch-ahead 1 = red [  
      rt 180      
      ]
      [
      rt random 50
      lt random 50    
      ]
     fd 1
     ]  
  
end

to return-home
  facexy 0 0
  fd 1
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
649
470
16
16
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
12
42
198
75
max-number-of-humans
max-number-of-humans
2
100
90
1
1
humans
HORIZONTAL

BUTTON
15
401
70
434
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
142
400
197
433
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
664
10
864
160
Human Population
ticks
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Total" 1.0 0 -16777216 true "" "plot count humans"
"Well fed" 1.0 0 -1184463 true "" "plot humans-well-fed"
"Hungry" 1.0 0 -13345367 true "" "plot humans-hungry"

SLIDER
13
336
198
369
food-piles
food-piles
5
30
30
1
1
piles
HORIZONTAL

SLIDER
12
75
197
108
max-human-age
max-human-age
20
100
25
1
1
years
HORIZONTAL

SLIDER
12
108
197
141
max-human-energy
max-human-energy
10
100
90
1
1
energy
HORIZONTAL

SLIDER
12
141
197
174
init-mean-energy-threshold
init-mean-energy-threshold
20
100
99
1
1
energy
HORIZONTAL

BUTTON
79
400
136
433
go once
go
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

PLOT
1095
10
1295
160
Human age
Age
People
0.0
100.0
0.0
20.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [age] of humans"

PLOT
880
10
1080
160
Energy Threshold
Ticks
Energy
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean-energy-threshold"

SLIDER
12
174
197
207
min-human-breeding-age
min-human-breeding-age
13
100
18
1
1
years
HORIZONTAL

SLIDER
12
206
197
239
mutation-factor
mutation-factor
0
20
17
1
1
percent
HORIZONTAL

SLIDER
246
525
431
558
max-wolf-energy
max-wolf-energy
20
100
80
1
1
energy
HORIZONTAL

SLIDER
440
483
624
516
max-wolf-age
max-wolf-age
1
50
30
1
1
years
HORIZONTAL

SLIDER
440
525
624
558
wolf-breed-energy-threshold
wolf-breed-energy-threshold
1
100
49
1
1
energy
HORIZONTAL

PLOT
664
179
864
329
Wolf Population
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count wolves"

SLIDER
12
271
198
304
max-number-of-wolves
max-number-of-wolves
1
100
99
1
1
wolves
HORIZONTAL

PLOT
880
179
1080
329
Wolf Energy
NIL
NIL
0.0
50.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [energy] of wolves"

SWITCH
246
482
430
515
wolf-dynamics
wolf-dynamics
1
1
-1000

TEXTBOX
82
16
232
34
Humans
12
0.0
1

TEXTBOX
84
247
234
265
Wolves
12
0.0
1

TEXTBOX
90
315
240
333
Food
12
0.0
1

TEXTBOX
90
375
240
393
Action
12
0.0
1

MONITOR
1122
219
1281
264
Human Mean Energy Threshold
mean-energy-threshold
3
1
11

@#$#@#$#@
## WHAT IS IT?

This model simulates situation where individual is forced to decide between two risky options. Either he roams world most of the time and risks being eaten by a predator, or he stays more time within safehouse, risking that he wont find enough food to survive.

## HOW IT WORKS

Model is defined like this:
In the beginning, specified number of humans and predators is set up, and there are randomly generated sources of food (indicated by green patch).
There are certain amount of predators, their movement is random. Then there are humans, who move randomly as well when searching for food. If they find it, they turn yellow and return to safehouse. Food replenishes energy to maximum (max-human-energy). They resume their search for nutrition only after reaching energy treshold. This treshold is randomly generated for each individual at the beginning. Every step, there are new kids born if there are at least two people at safehouse, they are older than min-human-breeding-age. New kids are born with randomly genereated energy threshold based on normal distrubution of humans who survived. Standart deviation represents mutation and it is set by mutation-facotr. Humans die after specified period of time (max-human-age).

## HOW TO USE IT

Setup - sets up food piles, safehouse, initial population of humans and predators.

max-number-of-humans - controls maximal population of humans (food source does not get depleted and in reality it would be limited, so population is limited by this variable)
max-human-age - one year of human life means one ticks - human dies after he reaches maximal age
max-human-energy - maximal energy human gets from finding food piles
init-mean-energy-threshold - initial threshold that represents the moment human needs to find food source
min-human-breeding-age - minimal age for human breeding
mutation-factor - represents standart deviation of energy-threshold for newborn human babies

max-number-of-wolves - controls maximal population of wolves (the same as for max-number-of-humans)

food-piles - controls initial number of food sources - increase to higher the ods of human survival

## THINGS TO NOTICE

As far as simulation goes, mean-energy-threshold is accustomed according to roughness of environment - how much food and how many predators there are. Behavior of humans in this model doesnt count with changing of human behavior when all predators die.

According to test output, mean-energy-threshold value mostly depends on human max-human-energy. 

## THINGS TO TRY

Try to change number of food piles and number of predators (wolves), so that you the difference in convergence of energy threshold.  

## EXTENDING THE MODEL

There is possibility to turn on wolf dynamincs - when wolf dynamics is on, wolves can also die because of energy depletion or because they are too old. They get food from eating humans. There are more setting of wolf dynamics:

max-wolf-energy - maximal amount of energy wolf gets from eating human
max-wolf-age - one year represents one tick
wolf-breed-energy-threshold - new wolf is born if wolf has more energy that this threshold

## NETLOGO FEATURES

Code is well commented. Feel free to check the implementation.

## RELATED MODELS

Ants, Wolves and sheep, Evolution.

## CREDITS AND REFERENCES

Martin Knapovský - knam00@vse.cz
Vojtěch Slánský - xslav21@vse.cz
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="The great experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <exitCondition>count(humans) = 0</exitCondition>
    <metric>mean-energy-threshold</metric>
    <steppedValueSet variable="max-number-of-wolves" first="10" step="20" last="100"/>
    <steppedValueSet variable="food-piles" first="1" step="5" last="30"/>
    <steppedValueSet variable="max-number-of-humans" first="10" step="20" last="100"/>
    <steppedValueSet variable="mutation-factor" first="1" step="10" last="20"/>
    <steppedValueSet variable="max-human-energy" first="10" step="20" last="100"/>
  </experiment>
  <experiment name="Human Age" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3000"/>
    <metric>mean-energy-threshold</metric>
    <steppedValueSet variable="max-human-age" first="20" step="5" last="80"/>
  </experiment>
  <experiment name="Wolves and Food Piles" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean-energy-threshold</metric>
    <steppedValueSet variable="food-piles" first="1" step="1" last="30"/>
    <steppedValueSet variable="max-number-of-wolves" first="1" step="1" last="100"/>
  </experiment>
  <experiment name="Init threshold and Mutation Die test" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count humans</metric>
    <steppedValueSet variable="init-mean-energy-threshold" first="1" step="2" last="100"/>
    <steppedValueSet variable="mutation-factor" first="1" step="2" last="20"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
