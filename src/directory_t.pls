create or replace type directory_t as object (
 /**
   Used to convert text to various pieces of a fully qualified path name.
   Recognized format is
   <ul>
   <li>//repository_name/directory/otherdirectories/more_subdirs/filename</li>
   <li>//repository_name</li>
   <li>/dirs/must/end/with/slash/</li>
   <li>filename</li>
   <li>filename@snippet</li>
   <li>and @snippet</li>
   </ul>
   Definition of valid characters and snippet separator are defined in the package <a>TEMPLATE_REPO_CONST</a>
   
   @headcom
 */
 repository varchar2(128),
 full_directory varchar2(4000),
 filename varchar2(4000),
 snippet varchar2(4000),
 /**
   constructor function based of string input.
   
   @param p_rdf_str String representing <b>R</bepostory <b>D</b>irectory, and <b>F</b>ilename
   @return SELF, Object with everything parsed out.
 */
 constructor function directory_t( p_fqp in varchar2 )
  return self as result
);
/
