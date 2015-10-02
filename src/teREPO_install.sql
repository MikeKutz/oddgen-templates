/* INSTALL by SQL*Plus */
@template_repo_const.pls
@template_repo_const.plb

@template_repo_interface_core.pls

@template_repo_interface_v1.pls
@template_repo_interface_v1.plb

@table_REPOSITORIES.sql
@repositories_admin.pls
--@repositories_admin.plb -- run AFTER drivers are created

@template_repository_obj.pls
@template_repository_obj.plb

@repo_driver_dbobj.pls
-- @repo_driver_dbobj.plb

@repositories_admin.plb
