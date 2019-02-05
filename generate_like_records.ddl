create or replace
procedure generate_likes
( p_collega_id in number)
is
begin
  insert into likes
  ( collegas_id, sessions_id) 
  select p_collega_id
  ,      s.id 
  from   sessions s left outer join likes l on (p_collega_id = l.collegas_id)
  where  l.id is null
  ;
end;