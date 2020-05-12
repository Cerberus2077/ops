DECLARE
  i number := 1;
BEGIN for i in 1 .. 11451 loop
insert into T_DEVICE_BRIDGE
    (id)
values (SYS_GUID());
end loop;
commit;
END;
