create or replace
package body template_repo_const
as
  
  -- this has been moved to the DIRECTORY_T object
  function extract_dir_info( p_directory in varchar2 ) return directory_t
  as
    l_res directory_t;
  begin
    -- TODO this needs much work
    l_res := directory_t( null, null, null,null );
    if p_directory is null then
      l_res.full_directory := '/';
    elsif p_directory = '/' then
      l_res.full_directory := '/';
    elsif regexp_like( p_directory, '^//[[:alnum:]]+$' ) then
      l_res.repository := p_directory;
      l_res.full_directory := '/';
      l_res.filename := null;
--    elsif p_directory like '//%' then
--       l_res.repository     :=  regexp_replace( p_directory, '^(//[[:alnum:]_\$- ]+)(/.*/?)([[:alnum:]_\$- ])$', '\1' ); -- regexp_extract??
--       l_res.full_directory :=  regexp_replace( p_directory, '^(//[[:alnum:]_\$- ]+)(/.*/?)([[:alnum:]_\$- ])?$', '\2' ); -- regexp_extract??
--       l_res.filename       := regexp_replace( p_directory, '^(//[[:alnum:]_\$- ]+)(/.*/?)([[:alnum:]_\$- ])?$', '\3' ); -- regexp_extract??
--    elsif p_directory like '/%' then
--       l_res.full_directory :=  regexp_replace( p_directory, '^(/.*/?)([[:alnum:]_\$- ])?$', '\2' ); -- regexp_extract??
--       l_res.filename       := regexp_replace( p_directory, '^(//[[:alnum:]_\$- ]+)(/.*/?)([[:alnum:]_\$- ]$', '\3' ); -- regexp_extract??
--
    else
      l_res.filename := p_directory;
    end if;
    return l_res;
  end;
  
  -- this is here for Unit Testing purposes
$if false $then
<%@ template name=test, version=0.1 %>
hello world
$end

$if false $then
<%@ template name=joshua, version=0.1 %>
Would you like to play a game?
$end

$if false $then
<%@ template name=parent, version=0.1 %>
The parent is first.
Now, the child
  <%@ include(TEMPLATE_REPO_CONST@child) %>

$end

$if false $then
<%@ template name=child, version=0.1 %>
The child is to old to start the training.
<%@ include(TEMPLATE_REPO_CONST@joshua) %>
$end

  
end;
/
