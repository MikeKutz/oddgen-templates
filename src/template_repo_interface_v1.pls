create or replace
type template_repo_interface_v1 under template_repo_interface_core (
   guid        varchar2(64), -- TODO replace with parent type repository_guid
   -- mount_point varchar2(128),
   pwd         varchar2(4000),
   base_url    varchar2(4000),
   /**
   This is the "interface" for template repository drivers.
   
   guid - must be unique
   mount_point must be unique.  must include "/" prefix.
   pwd - currect working directory
   base_url - this is defined by the driver.
   
   <p>
   <b>MUST IMPLEMENT</b> Driver developer MUST implement this function.<br>
   <b>MAY IMPLEMENT</b> Driver developer MAY implement this feature to add functionality.  enhance LIST_INTERFACES as needed.<br>
   <b>OPTIONAL IMPLEMENT</b> These are optional to implement if the developer feels that an improved method can be created.<br>
   </p>
   <p><h2>COMMANDS CLASS</h2>
   driver - used for information about the driver (eg get_type() ) and interaction (eg login/logout).
   filesystem - filesystem like interface
   webdav - simplified webdav like interface
   
   <p>
   <h2>DIRECTORIES</h2><br>
   begins with "//xxx" - xxx is a change of Repository.  Drivers must throw an error
   begins with "/" - absolute directory within current repository
   "somename" - relative file or directory

   @headcom
   */
   
   /**
     <b>MUST IMPLEMENT<b>
     Constructor functions are unique to each driver.
     pwd is set to "/"
     If possible, validity mu
     @param p_mount_point This is the "mount point" with in the PL/SQL Repository store house
     @param p_base_url This is defined by the driver.
    */
    CONSTRUCTOR function template_repo_interface_v1( p_mount_point in varchar2, p_base_url in varchar2 ) return self as result,
    
    /**
    type: driver
    impl: may impliment.
    note: must implement if you expand basic

    Returns a list of what interfaces have been implemented
    @return xml collection of availabel interfaces
    */
    not final static function list_interfaces return xmltype, -- todo fix to pipeline array type --*
    /**
    type: driver
    impl: optional
    
    quick check method for verifing if a driver implements a particular interface.
    
    @return true if interface exists
    */
    not final static function has_interface( p_interface_name in varchar2)  return boolean, --*

    /**
    type: filesystem
    impl: must implement if you support sub-directories
    
    Change Directory.
    If repository name is used, it must not change.
    If filename is given, it is ignored.
    
    @param p_directory Directory name to set for pwd.
    @throws repo_const.invalid_repository  thrown if you are changing repository
    @throws repo_const.invalid_directory   thrown if the directory is invalid
    */
    not final member procedure cd( p_directory in varchar2 := null ),
    
    /**
    type: filesystem
    impl: must implement if driver supports sub-directories
    
    Verifies that a particular directory is valid with in the scope of this repository
    @param p_directory This is the base directory to be check. default is current working directory
    @throws repo_const.invalid_directory   thrown if directory is invalid
    */
    not final member procedure check_dir( p_directory in varchar2 := null ),
    /**
    type: filesystem
    impl: must impliment.
    Checks a filename.  filename can be relative or absolute.
    @param p_file filename to check
    @throws repo_const.invalid_file       thrown if file is invalid.
    @throws repo_const.invalid_repository thrown if p_file crosses repositories
    @throws repo_const.invalid_directory  thrown if directory is invalid
    */
    not final member procedure check_file( p_file in varchar2 := null ),
    
    /**
    type: driver
    impl: must impliment.
    list all items in a specific direcotry.
    directory name can include filename
    blah
    */
    not final member function ls( p_directory in varchar2 := null ) return XMLType, -- todo fix to pipeline and/or AA --*

    /**
    type: filesyatem
    impl: may impliment.
    note: out-of-scope
    */
    not final member procedure md( p_directory in varchar2 := null ),
    not final member procedure rm( p_file in varchar2 ),
    not final member procedure rmdir( p_directory in varchar2, p_options in varchar2 := null ),
    
    not final member function get_code( p_file_name in varchar2 ) return clob, --*
    not final member function get_properties( p_file_name in varchar2 ) return xmltype,
    not final member function get( p_file_name in varchar2 ) return xmltype,
    not final member function propfind( p_directory in varchar2, p_depth in int, p_proplist in xmltype := null ) return xmltype,
    not final member procedure propupdate( p_file in varchar2, p_properties in xmltype ),
    not final member procedure put( p_file in varchar2, p_data in clob, p_properties in xmltype),
    not final member procedure makecol( p_directory in varchar2 )
) not final;
/
