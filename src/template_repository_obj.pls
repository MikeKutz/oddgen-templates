create or replace
type template_repository_obj as object (
  current_repo      template_repo_interface_v1,
  current_directory varchar2(4000),
  /** simplified object interface for accessing templates in multiple repositories.
    declare
      r repository_obj := repository_obj()
    begin
      r.cd( '//myfirst_repo' );
      template := r.get_code( '/a_file' );
      -- note SUB DIRECTORIES NOT ALWAYS SUPPORTED !!!
      template := r.get_code( '/a_dir/b_file' );
      r.cd('/a_dir');
      template := r.get_code( 'b_file' );
    end;
    @headcom
  */
  constructor function template_repository_obj return self as result,
  constructor function template_repository_obj( p_repodir in varchar2 ) return self as result,
  /** change directory and repository */
  member procedure cdr( p_repo in varchar2, p_directory in varchar2 ),
  /** change repository */
  member procedure cr(p_repo in varchar2 ),
  /** change directory within a repository. directory must be in current repository */
  member procedure cdd( p_directory in varchar2),

  /** use this one to change directory and repository in one easy go.  include the repository name for the first usage. */
  member procedure cd( p_directory in varchar2 ),
  member function get_code( p_filename in varchar2 ) return clob,
  member function ls( p_directory in varchar2 ) return xmltype
);
/
