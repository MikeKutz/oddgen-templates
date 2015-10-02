/* UNINSTALL */
-- drop package API, tables, and wrapper TYPE
drop package repositories_admin;
drop table repositories;
drop type template_repository_obj;

-- drop repository implementations (add others as needed)
drop type repo_driver_dbobj;
--drop type repo_driver_type1;
--drop type repo_driver_type2;

-- drop main interface(s)
drop type template_repo_interface_v1;
drop type template_repo_interface_core;

-- drop constants
drop package template_repo_const;




