
CREATE OR REPLACE
TYPE BODY template_repository_obj AS
  constructor function template_repository_obj return self as result
  as
  begin
    select value(r) into self.current_repo
    from repositories r
    where rownum = 1;

    self.current_repo.cd( '/' );
    self.current_directory := '/';
    return;
  exception
    when no_data_found then
      raise template_repo_const.invalid_repository;
  end;

  constructor function template_repository_obj( p_repodir in varchar2 ) return self as result
  as
    l_dir_info  directory_t;
  BEGIN
    l_dir_info := directory_t( p_repodir );

    if l_dir_info.repository is null then raise template_repo_const.invalid_repository; end if;
    if l_dir_info.full_directory is null then l_dir_info.full_directory := '/'; end if;

    cdr( l_dir_info.repository, l_dir_info.full_directory );
    return;
  end;

  member procedure cdr( p_repo in varchar2, p_directory in varchar2 ) AS
    l_backup_repo template_repo_interface_v1 := self.current_repo;
    l_backup_dir  varchar2(4000) := self.current_directory;
  BEGIN
    cr( p_repo );
    cdd( p_directory );
  exception
    when others then
      self.current_repo := l_backup_repo;
      self.current_directory := l_backup_dir;
      raise;
  END cdr;

  member procedure cr(p_repo in varchar2 ) AS
  BEGIN
    select value(r) into self.current_repo
    from repositories r
    where r.mount_point = p_repo;
    
    self.current_repo.cd( '/' );
    self.current_directory := '/';
  exception
    when no_data_found then
      raise template_repo_const.invalid_repository;
  END cr;

  member procedure cdd( p_directory in varchar2) AS
  BEGIN
    self.current_repo.cd( p_directory );
  END cdd;

  member procedure cd( p_directory in varchar2 ) AS
    l_dir_info  directory_t;
  BEGIN
    l_dir_info := template_repo_const.EXTRACT_DIR_INFO( p_directory );
    
    if l_dir_info.repository is null then l_dir_info.repository := current_repo.mount_point; end if;
    if l_dir_info.full_directory is null then l_dir_info.full_directory := '/'; end if;
    cdr( l_dir_info.repository, l_dir_info.full_directory );
  END cd;

  member function get_code( p_filename in varchar2 ) return clob AS
  BEGIN
    RETURN self.current_repo.get_code( p_filename);
  END get_code;

  member function ls( p_directory in varchar2 ) return xmltype AS
    l_dir_info directory_t;
    l_temp_repo template_repo_interface_v1;
  BEGIN
    l_dir_info := template_repo_const.EXTRACT_DIR_INFO( p_directory );
    if l_dir_info.repository = self.current_repo.mount_point
    then
      l_temp_repo := self.current_repo;
    else
      select value(r) into l_temp_repo
      from repositories r
      where r.mount_point = l_dir_info.repository;
    end if;
    
    return l_temp_repo.ls( p_directory );
  
  END ls;

END;
/
