/*
Patrik Magdolen	- xmagdo01
Juro Sojcak		- xsojca00
Filip Zelnicek	- xzelni00
Matous Jezersky	- xjezer01
*/

+step(0)
<-
	?grid_size(A,B);
	for ( .range(I, 0, A-1)) {
		for ( .range(J, 0, B-1)) {
			+unvisited((A-1)-I, (B-1)-J);
		}
	};
	+right(A);
	+down(B);
	+ivegotspectacles(3);
	do(skip).

+step(I): 
	unvisited(X, Y)
<-
	!updateMap;
	!findClosest(9999, M, Item_X, Item_Y);
	if (Item_X > -1 & Item_Y > -1) {
		!move_to(Item_X, Item_Y)
	}
	else {
		!atomStep(X, Y)
	}.

+step(I):
	true
<-
	!updateMap;
	!findClosest(9999, M, Item_X, Item_Y);
	if (Item_X > -1 & Item_Y > -1) {
		!move_to(Item_X, Item_Y)
	}
	else {
		do(skip)
	}.
	

+!findClosest(CurrMin, Min, MinX, MinY): 
	carrying_capacity(C) &
	((carrying_gold(G) & C == G) |  
	(carrying_wood(W) & C == W))
 <-
	?depot(MinX, MinY);
	Min = 42.

+!findClosest(CurrMin, Min, MinX, MinY): 
	map(X,Y,spectacles) &
	ivegotspectacles(3)
<-
	MinX = X;
	MinY = Y;
	Min = 42.

+!findClosest(CurrMin, Min, MinX, MinY): 
	map(X1,Y1,spectacles) &
	map(X2,Y2,spectacles) &
	(X1 \== X2 | Y1 \== Y2) &
	pos(X,Y) &
	ivegotspectacles(3)
<-
	dist(X, Y, X1, Y1, D1);
	dist(X, Y, X2, Y2, D2);
	if(D1 < D2){
		MinX = X1;
		MinY = Y1;	
	}
	else {
		MinX = X2;
		MinY = Y2;		
	}
	Min = 42.

+!findClosest(CurrMin, Min, MinX, MinY): 
	map(X,Y,Item) & 
	(Item == gold | Item == wood) & 
	not(tested(X,Y))  
<-
	+tested(X,Y);
	?pos(MyX,MyY);
	!dist(MyX, MyY, X,Y, CalcMin);
	/*CalcMin = Y;*/
	!findClosest(CalcMin, NewMin, NMX, NMY);
	if (NewMin < CalcMin) {
		Min = NewMin; 
		MinX = NMX; 
		MinY = NMY
	}
	else {
		Min = CalcMin; 
		MinX = X; 
		MinY = Y
	}.
	
+!findClosest(CurrMin, Min, MinX, MinY): 
	true 
<-
	Min = CurrMin; 
	MinX = -1; 
	MinY = -1; 
	.abolish(tested(_,_)).


+!dist(X1,Y1, X2,Y2, D): 
	true 
<-
	D = math.sqrt((X1-X2)*(X1-X2) + (Y1-Y2)*(Y1-Y2)).

+!clearHelpShoes(_, _).
+!clearHelp(_, _): 
	true 
<-
	.abolish(needHelp(_,_)).


+!remMap(X,Y,Item):
	map(X,Y,Item) 
<-
	.abolish(map(X,Y,Item)).

+!remMap(_,_,_).


+!updateGold(X,Y):
	gold(X,Y) &
	friend(A) &
	friend(B) &
	A \== B 
<-
	+map(X,Y, gold);
	.send(A, tell, map(X,Y, gold));
	.send(B, tell, map(X,Y, gold)).

+!updateGold(X,Y):
	map(X,Y, gold) &
	friend(A) &
	friend(B) &
	A \== B 
<-
	.abolish(map(X,Y, gold));
	.send(A, achieve, remMap(X,Y, gold));
	.send(B, achieve, remMap(X,Y, gold)).

+!updateGold(_,_).


+!updateWood(X,Y):
	wood(X,Y) &
	friend(A) &
	friend(B) &
	A \== B 
<-
	+map(X,Y, wood);
	.send(A, tell, map(X,Y, wood));
	.send(B, tell, map(X,Y, wood)).

+!updateWood(X,Y):
	map(X,Y, wood) &
	friend(A) &
	friend(B) &
	A \== B 
<-
	.abolish(map(X,Y, wood));
	.send(A, achieve, remMap(X,Y, wood));
	.send(B, achieve, remMap(X,Y, wood)).

+!updateWood(_,_).


+!updateObstacle(X,Y):
	obstacle(X,Y) &
	friend(A) &
	friend(B) &
	A \== B 
<-
	+map(X,Y, obstacle);
	.send(A, tell, map(X,Y, obstacle));
	.send(B, tell, map(X,Y, obstacle)).

+!updateObstacle(_,_).

+!updateShoes(X,Y):
	shoes(X,Y) &
	friend(A) &
	friend(B) &
	A \== B 
<-
	+map(X,Y, shoes);
	.send(A, tell, map(X,Y, shoes));
	.send(B, tell, map(X,Y, shoes)).

+!updateShoes(X,Y):
	map(X,Y, shoes) &
	friend(A) &
	friend(B) &
	A \== B 
<-
	.abolish(map(X,Y, shoes));
	.send(A, achieve, remMap(X,Y, shoes));
	.send(B, achieve, remMap(X,Y, shoes)).

+!updateShoes(_,_).

+!updateSpectacles(X,Y):
	spectacles(X,Y) &
	friend(A) &
	friend(B) &
	A \== B 
<-
	+map(X,Y, spectacles);
	.send(A, tell, map(X,Y, spectacles));
	.send(B, tell, map(X,Y, spectacles)).

+!updateSpectacles(X,Y):
	map(X,Y, spectacles) &
	friend(A) &
	friend(B) &
	A \== B 
<-
	.abolish(map(X,Y, spectacles));
	.send(A, achieve, remMap(X,Y, spectacles));
	.send(B, achieve, remMap(X,Y, spectacles)).

+!updateSpectacles(_,_).

@update[atomic] +!updateMap:
	pos(X,Y) &
	friend(A) &
	friend(B) &
	A \== B &
	ivegotspectacles(Spect)
<-
	for( .range(I, -Spect, Spect)){
		for( .range(J, -Spect, Spect)){
			!updateGold(X+I,Y+J);
			!updateWood(X+I,Y+J);
			!updateObstacle(X+I,Y+J);
			!updateShoes(X+I,Y+J);
			!updateSpectacles(X+I,Y+J);
			-unvisited(X+I,Y+J);
			.send(A, achieve, visited(X+I,Y+J));
			.send(B, achieve, visited(X+I,Y+J));
		}
	}.


+!visited(X, Y):
	true
<-
	.abolish(unvisited(X, Y)).


+gold(X,Y): 
	true
<-
	+map(X,Y,gold);
	!inform(X,Y,gold).  


+wood(X,Y): 
	true
<-
	+map(X,Y,wood);
	!inform(X,Y,wood).


+spectacles(X,Y): 
	true
<-
	+map(X,Y,spectacles).


+obstacle(X,Y): 
	true
<-
	+map(X,Y,obstacle);
	!inform(X,Y,obstacle).


+shoes(X,Y): 
	true
<-
	+map(X,Y,shoes);
	!inform(X,Y,shoes).


+!erase(X,Y):
	friend(A) &
	friend(B) &
	A \== B
<-
	.send(A, achieve, remMap(X,Y,_));
	.send(B, achieve, remMap(X,Y,_)).


+!inform(X, Y, Item):
	friend(A) &
	friend(B) &
	A \== B
<-
	.send(A, tell, map(X,Y,Item));
	.send(B, tell, map(X,Y,Item)).


+!atomStep(X,Y):
	pos(X,Y) &
	not(unvisited(X,Y))
<-
	do(skip).

@atstepslow[atomic] +!atomStep(X,Y): 
	true 
<-
	myLib.myIA(X, Y, R);
	if (R == skip) { -unvisited(X,Y); };
	do(R).


+!move_to(X,Y):
	pos(X,Y) &
	depot(X,Y) &
	((carrying_gold(G) & G > 0) |
	(carrying_wood(W) & W > 0))
<-
	do(drop).

@atmove[atomic] +!move_to(Item_X,Item_Y):
	pos(X,Y) &
	ally(X,Y) &
	X == Item_X &
	Y == Item_Y	&
	friend(A) &
	friend(B) &
	A \== B 
<-
	if(map(X,Y, spectacles)){
		-ivegotspectacles(3);
		+ivegotspectacles(6);
	}

	do(pick);
	.send(A, achieve, clearHelp(X,Y));
	.send(B, achieve, clearHelp(X,Y)).

+!move_to(Item_X,Item_Y):
	pos(X,Y) &
	X == Item_X &
	Y == Item_Y	&
	friend(A) &
	friend(B) &
	A \== B 
<-
	.send(A, tell, needHelp(X,Y));
	.send(B, tell, needHelp(X,Y));
	!erase(X,Y);
	do(skip).

@atmt2[atomic] +!move_to(X,Y):
	true
<-
	myLib.myIA(X, Y, R);
	do(R);
	!updateMap.

