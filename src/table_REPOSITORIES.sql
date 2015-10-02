create table repositories of template_repo_interface_v1;
alter table repositories
  add constraint repositories_guid_pk primary key (guid);
alter table repositories
  add constraint repositories_mp_uk unique (mount_point);
alter table repositories modify (mount_point not null );
