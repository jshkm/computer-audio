My final project focuses on sonifying data to help improve brushing your teeth. The user is tested throught 3 scenarios.

Scenario 1 (Pressure and Coverage): The data is sonified, so that when the pressure of brushing becomes too hard, the 
simulator responds by applying a highpass filter onto the sound of the tooth brush song playing, signaling the user to ease
on the pressure. At the same time, coverage data is being input to split the mouth into 4 quadrants. The sound of the woodblock
is started and stopped with an audio envelope, and slows down once it has been in a quadrant of the mouth for too long. In the
interactive mode, the user can control when to switch the quadrant of brushing, to keep up with the wood block when it slows 
down.

Scenario 2 (Angle): The data is sonified so that when the angle of the brush is tilted too much, it changes pitch. A waveplayer
synthesises sound which represents the angle, and when tilted past a safe amount, the pitch either goes up or down depending on
the direction. The user interacts with this by using a slider to represent the angle of which the brush is at, to change it and
see where the threshold of change is when changing the angle.

Scenario 3 (Speed): The data is sonified so that when the speed of the brush is too fast, the volume gets louder to alert the 
user to slow down. If the user continuously is brushing too fast, an audio alert will play to warn the user to "brush slower."
The user in this scenario can tap the keyboard letter 't' to create a timestamp in the console which prints the time they think
the volume begins to get louder. Also, a slider is used to visualize the speed of the brush to give the user a better 
understanding of the brushing speed. 