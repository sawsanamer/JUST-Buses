  # **Just Buses**
  
**Summary**
- A system that allows to book bus seats, view bus capacity, routes, pick up locations, and estimated arrival time to a specific location through a mobile application. This is made possible by a passenger counting system that is installed on the buses. The system is tailored for buses that do not use a schedule to operate.

**What is the purpose of this system in detail?**

Financial feasibility for informal public transport networks or private transport providers often necessitates filling the capacity of buses or vehicles. Thus, such transit cannot operate on a schedule and, unless the full capacity of the vehicles is reached, the vehicles (a) do not depart from their start point, or (b) make extended stops along their routes to fill capacity, or (c) reject picking up passengers along their routes. Therefore, an affordable structured solution is needed to tackle the problem, and thus the study at hand aims to: maximize transit vehicles filling of these capacities (i.e., their financial feasibility), minimize these filling times, and regulate the inflow of passengers. This all provides better mobility for citizens.

A sample transport system for this study was the bus transportation system serving routes to/from the Jordan University of Science and Technology (JUST) in Irbid, Jordan: It is a traditional system that does not utilize IT solutions, and accordingly its commuters face the mentioned struggles. Students must go to large public transit terminals, wait for buses to fill up, and then head to university. This comes with a high cost to students, in terms of their money, energy, and time: all scarce and very important resources to students.
 
This system came as a solution; combining hardware and software to count the number of passengers entering and exiting a bus in the main terminal/stop and along the route, and coordinates information with a mobile app allowing passengers to book from designated bus stops along the route. The app is usable by the bus driver to arrange the route and the stops he must make. This allows the buses to move faster, maximize ridership, increases flexibility for passengers beyond going to main terminals, and implements a more organized framework for a transit vehicle’s itinerary. A prototype of the hardware and software was developed and implemented to test the effectiveness of the proposed system, which showed to be a reliable solution to address the issue at hand.

**How to use the application**

This is a guide of how you can use the application/ further understand it.

**The general sign up/ sign in functionality.**

This provides a signing up functionality to all users. If the person enters the special code of the driver, they will be assigned a driver role and directed to that interface, likewise, if they enter the moderator code, they will be assigned the moderator role and directed to that interface. The special code can be obtained from the current moderators.  

<p float="left">
<img src="https://user-images.githubusercontent.com/71269773/151247547-fcac4b32-51c1-4d7b-ac4f-7d2866115441.png" height="407"  >
<img src="https://user-images.githubusercontent.com/71269773/151247676-1df1dd64-a45a-4501-a112-a900abd6eeb7.png" height="407"  >
</p>

**Part 1:The Student Application**

The student application aims to serve anyone who wants to go to university from any bus stop other than the main terminal.


**Home page:**

A map that shows all the available bus stops a person can book a bus seat from.

<img src="https://user-images.githubusercontent.com/71269773/151248722-73f9db90-b06a-4012-82b0-1cb116455184.png" height="407"  >

**Booking a ticket:**

When the student presses on a location, they are presented with a dialog box that asks if they want to book a ticket, and then they have to confirm it for the transaction to complete.

<p>
<img src="https://user-images.githubusercontent.com/71269773/151248863-bf37588a-ca99-468e-b07c-bc90739f2cea.png" height="407"  >
<img src="https://user-images.githubusercontent.com/71269773/151248943-16a1e9f6-ec82-4b2d-9de3-525b30ca02a1.png" height="407"  >
 </p>


**After booking:**

Once the student presses on confirm, there are two scenarios that might occur. The first is that there are no buses available; they are presented with a pop up that lets them know. Otherwise, they are presented with a map; to be able to track the bus location and view the estimated time for the bus to reach their specified  stop by pressing the “see estimated time” button.

<p>
<img src="https://user-images.githubusercontent.com/71269773/151249550-15993ce0-c7e4-47a2-8e05-153036ef659a.png"height="407"   >
<img src="https://user-images.githubusercontent.com/71269773/151249562-fd4c1f72-7741-4496-8459-4b8cc5e3e58c.png" height="407"  >
<img src="https://user-images.githubusercontent.com/71269773/151249777-a82b4fb5-7af4-4e8b-8bb2-4f2a7d58c9b6.png" height="407"  >
 </p>

**The menu:**

The student can press on the menu to view the amount of money they have in their wallet or log out 

<p>
<img src="https://user-images.githubusercontent.com/71269773/151250001-69de027e-6ff1-4d91-a378-d63cf76cbac2.png" height="407" >
<img src="https://user-images.githubusercontent.com/71269773/151250011-98a23282-f711-4df7-aff1-b9c88d1b62cf.png" height="407" >

  </p>




**Part 2: The Driver Application**

The driver application serves the drivers, to be able to view the number of available seats in their bus, view the bookings that are made from the bus stops, and see who the people who booked are. 

**Choosing driver type**

The first screen that the driver is presented with asks what type of driver they are.

*If the driver chooses that they are the current bus in the main terminal, it means that they are the bus that is currently picking students from the terminal. 

*If the driver chooses that they are the next bus in the terminal, it means that they are in queue and a bus in front of them is picking up students. 

*If the driver chooses neither, it means that they just have to wait until it is their turn in the main terminal as shown in the second figure.

<p>
<img src="https://user-images.githubusercontent.com/71269773/151250795-dbbbdf57-58a7-40e7-9c12-f3224d70a349.png" height="407"  >
<img src="https://user-images.githubusercontent.com/71269773/151250936-10175e0a-04e8-4929-805b-77bd1632f8ac.png" height="407"  >
</p>

**Choose main terminal crowdedness:**

Afterwards, they have to choose whether the main terminal is busy with students or not as shown in figure. If the terminal is busy with students,  they won’t receive any bookings if they are the current bus, instead, 8 bookings would be transferred to the next bus.

<img src="https://user-images.githubusercontent.com/71269773/151251325-b60652d9-6f26-4e7d-bc06-6a5ed06e1490.png" height="407" >


**The Map**

Subsequently, the driver is presented with a map. The map shows the driver location in real time on the map, the locations of bus stops where the students booked from, the number of available seats in the bus (based on bookings and the number of passengers who entered the bus in the terminal, counted by the hardware), and the number of bookings.

*If the driver is the current bus a button that says “Move Bus” appears below as shown in the first figure bellow. The driver should press it as soon as they decide to exit the terminal. Once they press on it:

*They get the “arrived” button as shown in the second figure, which should be pressed when they arrive at university  so that the bookings related to them, would all be deleted.

*On the other hand, if the driver is the next bus they wouldn’t have the option “Move Bus” as shown in the third figure.

<p>
<img src="https://user-images.githubusercontent.com/71269773/151251999-b64767c0-deec-46ed-b993-25d9897bb8a6.png" height="407" >
<img src="https://user-images.githubusercontent.com/71269773/151252020-3541e12e-6035-4040-90fe-98063fd1c5fb.png" height="407" >
<img src="https://user-images.githubusercontent.com/71269773/151252037-8e9aaebd-c29a-4d33-a153-d887e82a30ec.png" height="407" >
</p>


**View bookings and pick up students**

When the driver presses on a marker info window (the name of the location), they are presented with the students’ emails that have booked from that location. If the driver presses on the email, it means that they have picked up the student from the bus stop. 

<img src="https://user-images.githubusercontent.com/71269773/151252458-e23c6d9b-bc23-4801-9b27-d028e920baf5.png" height="407" >


**Navigation**

To navigate to the bus stop location the driver can press on the button below:

<img src="https://user-images.githubusercontent.com/71269773/151252662-e1aa4615-8019-49d2-92c3-4d2c2be0befe.png"  >


**Part 3: The Moderator Application**

A moderator is a person who manages a small office in the main terminal or university for managerial purposes. If you are a Moderator, this screen will appear on log in.

<img src="https://user-images.githubusercontent.com/71269773/151252982-7083b880-6061-410a-88d1-9143fc837003.png" height="407" >

**Adding money to a student’s wallet**

Students can head to the moderator office, where they will pay the amount that they want, and that amount is added to their wallet, to be able to use it in future bus seat bookings. 

<img src="https://user-images.githubusercontent.com/71269773/151253266-881e385f-7320-490c-91ab-ade39fc1bc69.png" height="407" >

**Changing moderator and driver codes**

One of the fundamental blocks in the system is having 3 separate roles for users. If a driver or a moderator wants to sign up, they have to head to the moderator's office to take the special code and enter it when they sign up.  The moderator can change that code, for security purposes. It is recommended that the code is changed almost daily. 

<p>
<img src="https://user-images.githubusercontent.com/71269773/151253546-4e8b2ba6-b62e-425d-8cda-ffcbdda5142e.png" height="407" >
<img src="https://user-images.githubusercontent.com/71269773/151253560-7e60efb7-d346-474e-9c5b-6159c35e35f2.png" height="407" >
</p>

**Adding/deleting a bus stop location**

The moderator can add new bus stop locations, by adding the longitude and latitude of that location, and it will appear on the student map. They can also delete an existing location by entering its name.

<p>
<img src="https://user-images.githubusercontent.com/71269773/151253759-23865d1b-3c89-49e1-80d9-ff04b34835bb.png" height="407" >
<img src="https://user-images.githubusercontent.com/71269773/151253770-43879bcd-7683-4bd2-b067-5d917afbaa4a.png" height="407" >
 </p>

**Part 4: The hardware**

**The used hardware**

The main components are 2 laser transmitter modules, 2 laser receiver modules, and a NodeMCU.

**How the hardware works together?**

The hardware components are installed on the entrance of the bus. How do these elements work together to count passengers? if the laser beam closest to the entrance is interrupted, followed by the other one, then we know that a passenger entered the bus. On the other hand, if the laser beam that is farther got interrupted first, we know that a person is getting off the bus. The Laser receivers’ modules detect the change in light when someone interrupts the laser beam. The NodeMCU is programmed to alert us every time someone enters/ gets off. This passenger counting is used to know the number of available seats in the bus, hence, allowing booking outside the main terminal.

**And that is it! Thank you for reading.**
