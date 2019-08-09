--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: continuous(integer); Type: FUNCTION; Schema: public; Owner: dt
--

CREATE FUNCTION public.continuous(mins integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
declare testval integer;


begin

-- testval := (select date_part('minutes',max(ts)) from temp) - (select date_part('minutes',ts) from temp order by ts desc offset mins limit 1) ;
testval := (select date_part('minute',(age(max(ts) , (select ts from temp order by ts desc offset mins limit 1)))) from temp);
return (testval = mod(mins,60));

end;
$$;


ALTER FUNCTION public.continuous(mins integer) OWNER TO dt;

--
-- Name: continuous2(); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.continuous2() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
declare testval integer = 1;

begin

testval := (select date_part('minutes',max(ts) - (select ts from temp order by ts desc offset mins limit 1)) from temp limit 1);

return (testval = mins%60);

end;
$$;


ALTER FUNCTION public.continuous2() OWNER TO esa;

--
-- Name: continuous3(integer); Type: FUNCTION; Schema: public; Owner: dt
--

CREATE FUNCTION public.continuous3(mins integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
declare testval integer;

begin

testval := (select date_part('minutes',max(ts) - (select ts from temp order by ts desc offset mins limit 1)) from temp limit 1);

return (testval = mins%60);

end;
$$;


ALTER FUNCTION public.continuous3(mins integer) OWNER TO dt;

--
-- Name: continuous_n(); Type: FUNCTION; Schema: public; Owner: dt
--

CREATE FUNCTION public.continuous_n() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
declare test integer;
declare testval integer;
declare last integer;
declare last1 integer;

begin
testval := 1;

test := 1;

while testval < 6 LOOP

last := (select id from temp  where id = (select max(id) from temp) order by ts desc offset testval);
last1 := last - 1;

test := (select date_part('minutes', age((select ts from temp where id = last order by ts desc offset testval), (select ts from temp where id = last1 order by ts desc offset (testval + 1) limit 1))));
testval := testval + 1;
-- test := test

END LOOP;

return testval;

end;
$$;


ALTER FUNCTION public.continuous_n() OWNER TO dt;

--
-- Name: FUNCTION continuous_n(); Type: COMMENT; Schema: public; Owner: dt
--

COMMENT ON FUNCTION public.continuous_n() IS 'returns value as minutes where serie is continuous';


--
-- Name: continuous_test(integer); Type: FUNCTION; Schema: public; Owner: dt
--

CREATE FUNCTION public.continuous_test(mins integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
declare ts_max integer;
declare ts_mins integer;

begin

ts_max := (select date_part('minutes',max(ts)) from temp);
ts_mins := (select date_part('minutes',ts) from temp order by ts desc offset mins limit 1) ;

return (ts_max = ts_mins);

end;
$$;


ALTER FUNCTION public.continuous_test(mins integer) OWNER TO dt;

--
-- Name: ennuste(integer); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.ennuste(integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
-- sisäiset muuttujat
declare slope numeric;
intercept numeric;
-- paluuarvo
enn numeric;

begin

-- haetaan näkymästä viim15 leikkauspisteen arvo sisäiseen muuttujaan
select (regr_intercept(anturi2, id)) into intercept from viim15;

-- haetaan näkymästä viim15 kulmakertoimen arvo sisäiseen muuttujaan
select (regr_slope(anturi2,id)) into slope from viim15;

-- lasketaan paluuarvo leikkauspisten ja kulmakertoimen summana joka kerrotaan parametrina annetulla aikayksiköllä
enn = intercept + slope * $1;
return round(enn, 2);

end;
$_$;


ALTER FUNCTION public.ennuste(integer) OWNER TO esa;

--
-- Name: ennuste10(numeric); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.ennuste10(numeric) RETURNS record
    LANGUAGE plpgsql
    AS $_$
-- sisäiset muuttujat
declare enn numeric;
declare aika numeric;
declare ret record;

begin

select (regr_intercept( id, paluu) + regr_slope( id, paluu) * $1) into enn from viim5;
select enn - max(id) into aika from viim5;

select round(aika,2), round(enn,2) into ret from viim5;


return ret;

end;
$_$;


ALTER FUNCTION public.ennuste10(numeric) OWNER TO esa;

--
-- Name: FUNCTION ennuste10(numeric); Type: COMMENT; Schema: public; Owner: esa
--

COMMENT ON FUNCTION public.ennuste10(numeric) IS 'usage: select aika, enn from ennuste10(50) f( aika numeric, enn numeric)';


--
-- Name: ennuste11(numeric); Type: FUNCTION; Schema: public; Owner: dt
--

CREATE FUNCTION public.ennuste11(numeric) RETURNS record
    LANGUAGE plpgsql
    AS $_$
-- sisäiset muuttujat
declare enn numeric;
declare aika numeric;
declare ret record;

begin

select (regr_intercept(paluu,  id) + regr_slope( paluu, id) * $1) into enn from viim30;
select enn - max(id) into aika from viim30;

select round(aika,0), round(enn,0) into ret from viim30;

return ret;

end;
$_$;


ALTER FUNCTION public.ennuste11(numeric) OWNER TO dt;

--
-- Name: ennuste2(integer); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.ennuste2(integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
declare slope float; intersect float; enn float;
begin select (regr_intersect(anturi2, id)) into intersect
from viim15;
select (regr_slope(anturi2,id)) into slope from viim15;
enn = intersect + slope * $1;
return enn;
end;
$_$;


ALTER FUNCTION public.ennuste2(integer) OWNER TO esa;

--
-- Name: ennuste3(integer); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.ennuste3(integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
declare slope float; intercept float; enn float;
begin select (regr_intercept(anturi2, id)) into intercept
from viim15;
select (regr_slope(anturi2,id)) into slope from viim15;
enn = intercept + slope * $1;
return enn;
end;
$_$;


ALTER FUNCTION public.ennuste3(integer) OWNER TO esa;

--
-- Name: ennuste4(integer); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.ennuste4(integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
declare slope numeric;
intercept numeric;
enn numeric;

begin select (regr_intercept(anturi2, id)) into intercept from v_viim10b;
select (regr_slope(anturi2,id)) into slope from v_viim10b;

enn = intercept + slope * $1;
return round(enn, 2);

end;
$_$;


ALTER FUNCTION public.ennuste4(integer) OWNER TO esa;

--
-- Name: ennuste6(integer); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.ennuste6(integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
-- sisäiset muuttujat
declare slope numeric;
intercept numeric;
-- paluuarvo
enn numeric;

begin

-- haetaan näkymästä viim15 leikkauspisteen arvo sisäiseen muuttujaan
select (regr_intercept(id, anturi2)) into intercept from viim5;

-- haetaan näkymästä viim15 kulmakertoimen arvo sisäiseen muuttujaan
select (regr_slope(id, anturi2)) into slope from viim5;

-- lasketaan paluuarvo leikkauspisten ja kulmakertoimen summana joka kerrotaan parametrina annetulla aikayksiköllä
enn = intercept + slope * $1;
return round(enn, 2);

end;
$_$;


ALTER FUNCTION public.ennuste6(integer) OWNER TO esa;

--
-- Name: ennuste7(numeric); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.ennuste7(numeric) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
-- sisäiset muuttujat
declare slope numeric;
intercept numeric;
-- paluuarvo
enn numeric;

begin

-- haetaan näkymästä viim15 leikkauspisteen arvo sisäiseen muuttujaan
select (regr_intercept(id, anturi2)) into intercept from viim5;

-- haetaan näkymästä viim15 kulmakertoimen arvo sisäiseen muuttujaan
select (regr_slope(id, anturi2)) into slope from viim5;

-- lasketaan paluuarvo leikkauspisten ja kulmakertoimen summana joka kerrotaan parametrina annetulla aikayksiköllä
enn = intercept + slope * $1;
return round(enn, 2);

end;
$_$;


ALTER FUNCTION public.ennuste7(numeric) OWNER TO esa;

--
-- Name: ennuste8(numeric); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.ennuste8(numeric) RETURNS record
    LANGUAGE plpgsql
    AS $_$
-- sisäiset muuttujat
declare enn numeric;
declare aika numeric;
declare ret record;

begin

select (regr_intercept( id, anturi2) + regr_slope( id, anturi2) * $1) into enn from viim5;
select enn - max(id) into aika from viim5;

select round(aika,2), round(enn,2) into ret from viim5;

return ret;

end;
$_$;


ALTER FUNCTION public.ennuste8(numeric) OWNER TO esa;

--
-- Name: ennuste9(numeric); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.ennuste9(numeric) RETURNS record
    LANGUAGE plpgsql
    AS $_$
-- sisäiset muuttujat
declare enn numeric;
declare aika numeric;
declare ret record;

begin

select (regr_intercept( id, paluu) + regr_slope( id, paluu) * $1) into enn from viim5;
select enn - max(id) into aika from viim5;

select round(aika,2), round(enn,2) into ret from viim5;

return ret;

end;
$_$;


ALTER FUNCTION public.ennuste9(numeric) OWNER TO esa;

--
-- Name: ennuste_ng(integer); Type: FUNCTION; Schema: public; Owner: dt
--

CREATE FUNCTION public.ennuste_ng(integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
-- sisäiset muuttujat
declare slope numeric;
intercept numeric;
-- paluuarvo
enn numeric;

begin

-- haetaan näkymästä viim10 leikkauspisteen arvo sisäiseen muuttujaan
select (regr_intercept(paluu, id)) into intercept from viim30;

-- haetaan näkymästä viim10 kulmakertoimen arvo sisäiseen muuttujaan
select (regr_slope(paluu,id)) into slope from viim30;

-- lasketaan paluuarvo leikkauspisten ja kulmakertoimen summana joka kerrotaan parametrina annetulla aikayksiköllä
enn = intercept + slope * $1;
return round(enn, 2);

end;
$_$;


ALTER FUNCTION public.ennuste_ng(integer) OWNER TO dt;

--
-- Name: ennuste_ng_1(integer); Type: FUNCTION; Schema: public; Owner: dt
--

CREATE FUNCTION public.ennuste_ng_1(integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
-- sisäiset muuttujat

declare 
	slope numeric;
	intercept numeric;
	maxid integer;
	-- paluuarvo
	enn numeric;

begin

select max(id) into maxid from viim30;
-- haetaan näkymästä viim30 leikkauspisteen arvo sisäiseen muuttujaan
select (regr_intercept(paluu, id)) into intercept from viim30;

-- haetaan näkymästä viim30 kulmakertoimen arvo sisäiseen muuttujaan
select (regr_slope(paluu,id)) into slope from viim30;

-- lasketaan paluuarvo leikkauspisten ja kulmakertoimen summana joka kerrotaan parametrina annetulla aikayksiköllä
-- enn = (intercept + slope * $1) + maxid ;
enn = (slope * $1) ;
return round(enn, 2);

end;
$_$;


ALTER FUNCTION public.ennuste_ng_1(integer) OWNER TO dt;

--
-- Name: hoo(); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.hoo() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
declare diff integer := 0;
declare testval integer := 0;
declare last integer;
declare seclast integer;

begin

while diff <= 1 LOOP

last := (select id from temp  where id = (select (max(id) - testval) from temp));
-- seclast := last - 1;

diff := (select date_part('minutes', age((select ts from temp where id = last), (select ts from temp where id = (last - 1) ))));
testval := testval + 1;
last := last - 1;

END LOOP;

return testval;

end;
$$;


ALTER FUNCTION public.hoo() OWNER TO esa;

--
-- Name: huu(); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.huu() RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
declare testval integer;
declare maxminutes integer;
declare minminutes integer;
declare retval boolean;
declare subtract integer := 9;
begin

-- select (date_part('minutes',(select max(ts) - min(ts)from temp limit 1 ))) into testval from temp limit 10;
-- testval := (select (date_part('minutes',(select max(ts) - min(ts)from (select ts from temp limit 10 )as otos  )))as testval from temp limit 1);

--maxminutes := (select (date_part('minutes',(select max(ts)from temp))));
-- minminutes := (select (date_part('minutes',(select ts from temp order by ts desc offset 10 limit 1))));
testval := (select date_part('minutes',max(ts) - (select ts from temp order by ts desc offset 10 limit 1)) from temp);


if testval = 10 then
-- if minminutes = (select (date_part('minutes',(select max(ts)from temp))))
--	then
	retval = true;
	else retval = false;
end if;

return retval;

end;
$$;


ALTER FUNCTION public.huu() OWNER TO esa;

--
-- Name: huu(integer); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.huu(mins integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
declare testval integer;
declare retval boolean;
begin

testval := (select date_part('minutes',max(ts) - (select ts from temp order by ts desc offset mins limit 1)) from temp limit 1);


-- if testval = mins then
--	retval = true;
--	else retval = false;
--end if;

-- return retval;
return (testval = mins%60);

end;
$$;


ALTER FUNCTION public.huu(mins integer) OWNER TO esa;

--
-- Name: huu2(integer); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.huu2(mins integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
declare testval integer;
declare maxminutes integer;
declare minminutes integer;
declare retval boolean;
declare subtract integer := 9;
begin

-- select (date_part('minutes',(select max(ts) - min(ts)from temp limit 1 ))) into testval from temp limit 10;
-- testval := (select (date_part('minutes',(select max(ts) - min(ts)from (select ts from temp limit 10 )as otos  )))as testval from temp limit 1);

--maxminutes := (select (date_part('minutes',(select max(ts)from temp))));
-- minminutes := (select (date_part('minutes',(select ts from temp order by ts desc offset 10 limit 1))));
testval := (select date_part('minutes',max(ts) - (select ts from temp order by ts desc offset mins limit 1)) from temp);


if testval = mins then
-- if minminutes = (select (date_part('minutes',(select max(ts)from temp))))
--	then
	retval = true;
	else retval = false;
end if;

return retval;

end;
$$;


ALTER FUNCTION public.huu2(mins integer) OWNER TO esa;

--
-- Name: iscontiguous(); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.iscontiguous() RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
declare testval integer;
declare retval boolean;
declare subtract integer := 9;
begin

select (date_part('minutes',(select max(ts) - min(ts)from viim10))) into testval from viim10 group by (1);
if testval = subtract then
	retval = true;
	else retval = false;
end if;

return retval;

end;
$$;


ALTER FUNCTION public.iscontiguous() OWNER TO esa;

--
-- Name: isserie(); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.isserie() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
declare retval integer;
begin

select (date_part('minutes',(select max(ts) - min(ts)from viim5))) into retval from viim5 ;
return retval;

end;
$$;


ALTER FUNCTION public.isserie() OWNER TO esa;

--
-- Name: isserie2(); Type: FUNCTION; Schema: public; Owner: esa
--

CREATE FUNCTION public.isserie2() RETURNS boolean
    LANGUAGE plpgsql
    AS $$ 
declare value integer;
declare retval boolean;
begin

select (date_part('minutes',(select max(ts) - min(ts)from viim10))) into value from viim10 ;
if value = 9 then
	retval = true;
	else retval = false;
end if;

return retval;

end;
$$;


ALTER FUNCTION public.isserie2() OWNER TO esa;

--
-- Name: myfunction(); Type: FUNCTION; Schema: public; Owner: dt
--

CREATE FUNCTION public.myfunction() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    
    last integer;
    counter integer := 0;
  BEGIN
    LOOP

last = ( select l.id
from temp as l
	left outer join temp as r on date_part('minute',r.ts) = date_part('minute',l.ts ) +1
	where r.ts is null order by l.ts desc limit 1);
	counter := counter + 1;
      EXIT WHEN counter > 1;
    END LOOP;
    RETURN last;
  END;
$$;


ALTER FUNCTION public.myfunction() OWNER TO dt;

--
-- Name: slope(integer); Type: FUNCTION; Schema: public; Owner: dt
--

CREATE FUNCTION public.slope(mins integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
declare retval numeric;

begin

retval := (select regr_slope( paluu,id) * 60 from (
 SELECT 
    temp2.paluu,
    temp2.id
   FROM ( SELECT 
            temp.paluu,
            temp.id
           FROM temp
          ORDER BY temp.id DESC
         LIMIT mins) as temp2
  ORDER BY temp2.id) as ali);

  if(continuous(mins)) then
  return round(retval,2);
  else return 0;
  end if;

  end;
  $$;


ALTER FUNCTION public.slope(mins integer) OWNER TO dt;

--
-- Name: trend_y(integer); Type: FUNCTION; Schema: public; Owner: dt
--

CREATE FUNCTION public.trend_y(integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
-- sisäiset muuttujat

declare 
	slope numeric;
	intercept numeric;
	
	-- paluuarvo
	trend_y numeric;

begin


-- haetaan näkymästä viim30 leikkauspisteen arvo sisäiseen muuttujaan
select (regr_intercept(paluu, id)) into intercept from viim30;

-- haetaan näkymästä viim30 kulmakertoimen arvo sisäiseen muuttujaan
select (regr_slope(paluu,id)) into slope from viim30;

-- lasketaan paluuarvo leikkauspisten ja kulmakertoimen summana joka kerrotaan parametrina annetulla aikayksiköllä
trend_y = intercept + slope * $1 ;
return round(trend_y, 2);

end;
$_$;


ALTER FUNCTION public.trend_y(integer) OWNER TO dt;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: temp; Type: TABLE; Schema: public; Owner: dt; Tablespace: 
--

CREATE TABLE public.temp (
    ts timestamp without time zone DEFAULT ('now'::text)::timestamp(0) without time zone NOT NULL,
    ulko numeric(4,2) DEFAULT 0 NOT NULL,
    meno numeric(4,2) DEFAULT 0 NOT NULL,
    paluu numeric(4,2) DEFAULT 0 NOT NULL,
    id integer NOT NULL,
    date date DEFAULT ('now'::text)::timestamp(0) without time zone NOT NULL,
    "time" time without time zone DEFAULT ('now'::text)::timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.temp OWNER TO dt;

--
-- Name: viim10; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim10 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 10) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim10 OWNER TO dt;

--
-- Name: avg10; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.avg10 AS
 SELECT round(avg(viim10.ulko), 1) AS ulko,
    round(avg(viim10.meno), 1) AS meno,
    round(avg(viim10.paluu), 1) AS paluu
   FROM public.viim10;


ALTER TABLE public.avg10 OWNER TO dt;

--
-- Name: viim120; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim120 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 120) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim120 OWNER TO dt;

--
-- Name: avg120; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.avg120 AS
 SELECT round(avg(viim120.ulko), 1) AS ulko,
    round(avg(viim120.meno), 1) AS meno,
    round(avg(viim120.paluu), 1) AS paluu
   FROM public.viim120;


ALTER TABLE public.avg120 OWNER TO dt;

--
-- Name: viim1440; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim1440 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 1440) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim1440 OWNER TO dt;

--
-- Name: avg1440; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.avg1440 AS
 SELECT round(avg(viim1440.ulko), 1) AS ulko,
    round(avg(viim1440.meno), 1) AS meno,
    round(avg(viim1440.paluu), 1) AS paluu
   FROM public.viim1440;


ALTER TABLE public.avg1440 OWNER TO dt;

--
-- Name: viim30c; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim30c AS
 SELECT temp2.hhmm,
    temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT to_char(temp.ts, 'YYYY-MM-DD"T"HH24:MI'::text) AS hhmm,
            temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 30) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim30c OWNER TO dt;

--
-- Name: avg30; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.avg30 AS
 SELECT round(avg(viim30c.ulko), 1) AS ulko,
    round(avg(viim30c.meno), 1) AS meno,
    round(avg(viim30c.paluu), 1) AS paluu
   FROM public.viim30c;


ALTER TABLE public.avg30 OWNER TO dt;

--
-- Name: viim300; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim300 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 300) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim300 OWNER TO dt;

--
-- Name: avg300; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.avg300 AS
 SELECT round(avg(viim300.ulko), 1) AS ulko,
    round(avg(viim300.meno), 1) AS meno,
    round(avg(viim300.paluu), 1) AS paluu
   FROM public.viim300;


ALTER TABLE public.avg300 OWNER TO dt;

--
-- Name: viim360; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim360 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 360) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim360 OWNER TO dt;

--
-- Name: avg360; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.avg360 AS
 SELECT round(avg(viim360.ulko), 1) AS ulko,
    round(avg(viim360.meno), 1) AS meno,
    round(avg(viim360.paluu), 1) AS paluu
   FROM public.viim360;


ALTER TABLE public.avg360 OWNER TO dt;

--
-- Name: viim60; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim60 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 60) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim60 OWNER TO dt;

--
-- Name: avg60; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.avg60 AS
 SELECT round(avg(viim60.ulko), 1) AS ulko,
    round(avg(viim60.meno), 1) AS meno,
    round(avg(viim60.paluu), 1) AS paluu
   FROM public.viim60;


ALTER TABLE public.avg60 OWNER TO dt;

--
-- Name: viim600; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim600 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 600) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim600 OWNER TO dt;

--
-- Name: avg600; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.avg600 AS
 SELECT round(avg(viim600.ulko), 1) AS ulko,
    round(avg(viim600.meno), 1) AS meno,
    round(avg(viim600.paluu), 1) AS paluu
   FROM public.viim600;


ALTER TABLE public.avg600 OWNER TO dt;

--
-- Name: viim720; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim720 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 720) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim720 OWNER TO dt;

--
-- Name: avg720; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.avg720 AS
 SELECT round(avg(viim720.ulko), 1) AS ulko,
    round(avg(viim720.meno), 1) AS meno,
    round(avg(viim720.paluu), 1) AS paluu
   FROM public.viim720;


ALTER TABLE public.avg720 OWNER TO dt;

--
-- Name: viim90; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim90 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 90) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim90 OWNER TO dt;

--
-- Name: avg90; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.avg90 AS
 SELECT round(avg(viim90.ulko), 1) AS ulko,
    round(avg(viim90.meno), 1) AS meno,
    round(avg(viim90.paluu), 1) AS paluu
   FROM public.viim90;


ALTER TABLE public.avg90 OWNER TO dt;

--
-- Name: retval; Type: TABLE; Schema: public; Owner: esa; Tablespace: 
--

CREATE TABLE public.retval (
    "?column?" interval
);


ALTER TABLE public.retval OWNER TO esa;

--
-- Name: temp2; Type: TABLE; Schema: public; Owner: dt; Tablespace: 
--

CREATE TABLE public.temp2 (
    ts timestamp without time zone DEFAULT ('now'::text)::timestamp(0) without time zone NOT NULL,
    ulko numeric(4,2) DEFAULT 0 NOT NULL,
    meno numeric(4,2) DEFAULT 0 NOT NULL,
    paluu numeric(4,2) DEFAULT 0 NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.temp2 OWNER TO dt;

--
-- Name: temp2_id_seq; Type: SEQUENCE; Schema: public; Owner: dt
--

CREATE SEQUENCE public.temp2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.temp2_id_seq OWNER TO dt;

--
-- Name: temp2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dt
--

ALTER SEQUENCE public.temp2_id_seq OWNED BY public.temp2.id;


--
-- Name: temp_id_seq; Type: SEQUENCE; Schema: public; Owner: dt
--

CREATE SEQUENCE public.temp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.temp_id_seq OWNER TO dt;

--
-- Name: temp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dt
--

ALTER SEQUENCE public.temp_id_seq OWNED BY public.temp.id;


--
-- Name: test; Type: TABLE; Schema: public; Owner: dt; Tablespace: 
--

CREATE TABLE public.test (
    id integer,
    paluu numeric(4,2)
);


ALTER TABLE public.test OWNER TO dt;

--
-- Name: test2; Type: TABLE; Schema: public; Owner: dt; Tablespace: 
--

CREATE TABLE public.test2 (
    ts timestamp without time zone,
    ulko numeric(4,2),
    meno numeric(4,2),
    paluu numeric(4,2),
    id integer
);


ALTER TABLE public.test2 OWNER TO dt;

--
-- Name: trendtest; Type: TABLE; Schema: public; Owner: dt; Tablespace: 
--

CREATE TABLE public.trendtest (
    id integer NOT NULL,
    paluu numeric(4,2)
);


ALTER TABLE public.trendtest OWNER TO dt;

--
-- Name: trendtest_id_seq; Type: SEQUENCE; Schema: public; Owner: dt
--

CREATE SEQUENCE public.trendtest_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trendtest_id_seq OWNER TO dt;

--
-- Name: trendtest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dt
--

ALTER SEQUENCE public.trendtest_id_seq OWNED BY public.trendtest.id;


--
-- Name: usagedaily; Type: VIEW; Schema: public; Owner: esa
--

CREATE VIEW public.usagedaily AS
 SELECT temp.date,
    round(avg(temp.meno), 2) AS avg_meno,
    count(temp.id) AS hits,
    round(((count(temp.id))::numeric / 1440.00), 2) AS usage
   FROM public.temp
  GROUP BY temp.date
  ORDER BY temp.date;


ALTER TABLE public.usagedaily OWNER TO esa;

--
-- Name: usagedaily2; Type: VIEW; Schema: public; Owner: esa
--

CREATE VIEW public.usagedaily2 AS
 SELECT temp.date,
    round(avg(temp.meno), 2) AS avg_meno,
    count(temp.id) AS hits,
    round(((count(temp.id))::numeric / 1440.00), 2) AS usage
   FROM public.temp
  WHERE (temp.meno > (40)::numeric)
  GROUP BY temp.date
  ORDER BY temp.date;


ALTER TABLE public.usagedaily2 OWNER TO esa;

--
-- Name: viim1; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim1 AS
 SELECT temp.ts,
    temp.ulko,
    temp.meno,
    temp.paluu,
    temp.id
   FROM public.temp
  ORDER BY temp.ts DESC
 LIMIT 5;


ALTER TABLE public.viim1 OWNER TO dt;

--
-- Name: viim10b; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim10b AS
 SELECT temp10.ts,
    temp10.ulko,
    temp10.meno,
    temp10.paluu,
    temp10.id,
    row_number() OVER () AS row_number
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id,
            temp.date,
            temp."time"
           FROM public.temp
          ORDER BY temp.id DESC
         LIMIT 10) temp10
  ORDER BY temp10.id DESC;


ALTER TABLE public.viim10b OWNER TO dt;

--
-- Name: viim10c; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim10c AS
 SELECT temp2.hhmm,
    temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT to_char(temp.ts, 'YYYY-MM-DD"T"HH24:MI'::text) AS hhmm,
            temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 10) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim10c OWNER TO dt;

--
-- Name: viim1440c; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim1440c AS
 SELECT temp2.hhmm,
    temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT to_char(temp.ts, 'YYYY-MM-DD"T"HH24:MI'::text) AS hhmm,
            temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 1440) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim1440c OWNER TO dt;

--
-- Name: viim15; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim15 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 15) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim15 OWNER TO dt;

--
-- Name: viim30; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim30 AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 30) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim30 OWNER TO dt;

--
-- Name: viim300c; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim300c AS
 SELECT temp2.hhmm,
    temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT to_char(temp.ts, 'YYYY-MM-DD"T"HH24:MI'::text) AS hhmm,
            temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 300) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim300c OWNER TO dt;

--
-- Name: viim30b; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim30b AS
 SELECT temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    row_number() OVER () AS row_number
   FROM ( SELECT temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            row_number() OVER () AS row_number
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 30) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim30b OWNER TO dt;

--
-- Name: viim360c; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim360c AS
 SELECT temp2.hhmm,
    temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT to_char(temp.ts, 'YYYY-MM-DD"T"HH24:MI'::text) AS hhmm,
            temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 360) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim360c OWNER TO dt;

--
-- Name: viim5; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim5 AS
 SELECT temp.ts,
    temp.ulko,
    temp.meno,
    temp.paluu,
    temp.id
   FROM public.temp
  ORDER BY temp.ts DESC
 LIMIT 5;


ALTER TABLE public.viim5 OWNER TO dt;

--
-- Name: viim60c; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim60c AS
 SELECT temp2.hhmm,
    temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT to_char(temp.ts, 'YYYY-MM-DD"T"HH24:MI'::text) AS hhmm,
            temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 60) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim60c OWNER TO dt;

--
-- Name: viim720c; Type: VIEW; Schema: public; Owner: dt
--

CREATE VIEW public.viim720c AS
 SELECT temp2.hhmm,
    temp2.ts,
    temp2.ulko,
    temp2.meno,
    temp2.paluu,
    temp2.id
   FROM ( SELECT to_char(temp.ts, 'YYYY-MM-DD"T"HH24:MI'::text) AS hhmm,
            temp.ts,
            temp.ulko,
            temp.meno,
            temp.paluu,
            temp.id
           FROM public.temp
          ORDER BY temp.ts DESC
         LIMIT 720) temp2
  ORDER BY temp2.ts;


ALTER TABLE public.viim720c OWNER TO dt;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: dt
--

ALTER TABLE ONLY public.temp ALTER COLUMN id SET DEFAULT nextval('public.temp_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: dt
--

ALTER TABLE ONLY public.temp2 ALTER COLUMN id SET DEFAULT nextval('public.temp2_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: dt
--

ALTER TABLE ONLY public.trendtest ALTER COLUMN id SET DEFAULT nextval('public.trendtest_id_seq'::regclass);


--
-- Name: id_pk; Type: CONSTRAINT; Schema: public; Owner: dt; Tablespace: 
--

ALTER TABLE ONLY public.trendtest
    ADD CONSTRAINT id_pk PRIMARY KEY (id);


--
-- Name: key2_dt; Type: CONSTRAINT; Schema: public; Owner: dt; Tablespace: 
--

ALTER TABLE ONLY public.temp2
    ADD CONSTRAINT key2_dt PRIMARY KEY (ts);


--
-- Name: key_dt; Type: CONSTRAINT; Schema: public; Owner: dt; Tablespace: 
--

ALTER TABLE ONLY public.temp
    ADD CONSTRAINT key_dt PRIMARY KEY (ts);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

