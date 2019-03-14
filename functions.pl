

not( X ) :- X, !, fail.
not( _ ).

radian(degmin(Degree,Min),Rad):-
  Rad is (Degree+Min/60)*pi /180.

haversine_distance(Lat1, Lon1, Lat2, Lon2, Distance) :-
  radian(Lat1,RadLat1),
  radian(Lat2,RadLat2),
  radian(Lon1,RadLong1),
  radian(Lon2,RadLong2),
  Dlon is RadLong2 - RadLong1,
  Dlat is RadLat2 - RadLat1,
  A is sin( Dlat / 2 ) ** 2
     + cos( RadLat1 ) * cos( RadLat2 ) * sin( Dlon / 2 ) ** 2,
  Dist is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
  Distance is Dist * 3961.

flightTime(Airport1,Airport2,Time):-
  airport(Airport1,_,Lat1,Long1),
  airport(Airport2,_,Lat2,Long2),
  haversine_distance(Lat1,Long1,Lat2,Long2,Dist),
  Time is Dist/500.

convertTime(Time,Hours,Mins):-
  Hours is floor(Time),
  Mins is floor((Time-Hours)*60).

convertDepTime(time(Hr,Min),Time):-
  Time is Hr+(Min/60).



  writepath( [] ) :-
     nl.
  %writepath( [Head|Tail] ) :-
  %   write( ' ' ), write( Head ), writepath( Tail ).

  writepath( [flight(Depart, Arrive, Depart_time)|List] ) :-
    airport(Depart, Depart_name, _, _),
    airport(Arrive, Arrive_name, _, _),
    write(Depart), write('  '), write(Depart_name),
    write('  '), write(Depart_time), nl,
    write(Arrive), write('  '), write(Arrive_name),
    write('  '), write(Arrive_time),
    writepath(List).


  listpath( Node, End, [flight(Node,Next,Time)|Outlist] ) :-
    flight(Node,Next,Time),
    listpath( Next, End, [flight(Node,Next,Time)], Outlist ).

  listpath( Node, Node, _, [] ).
  listpath( Node, End,
            [flight(PrevNode,PrevNext,PrevTime)|Tried],
            [flight( Node, Next,Time)|List] ) :-
     flight( Node, Next,Time),
     flightTime(PrevNode,PrevNext,TravTime),
     convertDepTime(PrevTime,PrevDeps),
     ArrTime is TravTime + PrevDeps,
     convertDepTime(Time,DepTime),
     ArrTime + 0.5 < DepTime,
     ComTried = append([flight(PrevNode,PrevNext,PrevTime)],Tried),
     not( member(Next,ComTried )),
     not(Next = PrevNext),
     listpath( Next, End, [flight( Node, Next,Time)|ComTried], List ).

  fly(Airport1,Airport2):-
    listpath(Airport1,Airport2,List),!,
    writepath(List).
