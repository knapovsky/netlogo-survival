# Survival
![ArticleTitle](http://images.knapovsky.com/jonas.jpg)

## WHAT IS IT?

This model simulates situation where individual is forced to decide between two risky options. Either he roams world most of the time and risks being eaten by a predator, or he stays more time within safehouse, risking that he wont find enough food to survive.

## HOW IT WORKS

Model is defined like this: In the beginning, specified number of humans and predators is set up, and there are randomly generated sources of food (indicated by green patch). There are certain amount of predators, their movement is random. Then there are humans, who move randomly as well when searching for food. If they find it, they turn yellow and return to safehouse. Food replenishes energy to maximum (_max-human-energy_). They resume their search for nutrition only after reaching energy treshold. This treshold is randomly generated for each individual at the beginning. Every step, there are new kids born if there are at least two people at safehouse, they are older than _min-human-breeding-age_. New kids are born with randomly genereated energy threshold based on normal distrubution of humans who survived. Standart deviation represents mutation and it is set by _mutation-factor_. Humans die after specified period of time (_max-human-age_).

## HOW TO USE IT

Setup - sets up food piles, safehouse, initial population of humans and predators.

- _max-number-of-humans_ - controls maximal population of humans (food source does not get depleted and in reality it would be limited, so population is limited by this variable)
- _max-human-age_ - one year of human life means one ticks - human dies after he reaches maximal age
- _max-human-energy_ - maximal energy human gets from finding food piles
- _init-mean-energy-threshold_ - initial threshold that represents the moment human needs to find food source
- _min-human-breeding-age_ - minimal age for human breeding
- _mutation-factor_ - represents standart deviation of energy-threshold for newborn human babies
- _max-number-of-wolves_ - controls maximal population of wolves (the same as for _max-number-of-humans_)
- _food-piles_ - controls initial number of food sources - increase to higher the ods of human survival

## THINGS TO NOTICE

As far as simulation goes, _mean-energy-threshold_ is accustomed according to roughness of environment - how much food and how many predators there are. Behavior of humans in this model doesnt count with changing of human behavior when all predators die.

According to test output, _mean-energy-threshold_ value mostly depends on human _max-human-energy_.

## THINGS TO TRY

Try to change number of food piles and number of predators (wolves), so that you the difference in convergence of energy threshold.

## EXTENDING THE MODEL

There is possibility to turn on wolf dynamincs - when wolf dynamics is on, wolves can also die because of energy depletion or because they are too old. They get food from eating humans. There are more setting of wolf dynamics:

- _max-wolf-energy_ - maximal amount of energy wolf gets from eating human
- _max-wolf-age_ - one year represents one tick _wolf-breed-energy-threshold_ - new wolf is born if wolf has more energy that this threshold

## NETLOGO FEATURES

Code is well commented. Feel free to check the implementation.

## RELATED MODELS

Ants, Wolves and sheep, Evolution.

## CREDITS AND REFERENCES

Martin Knapovský - [knam00@vse.cz](mailto:knam00@vse.cz) Vojtěch Slánský - [xslav21@vse.cz](mailto:xslav21@vse.cz)
