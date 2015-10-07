-- drop type repo_driver_dbobj force;
create or replace
type body repo_driver_dbobj
as


   /**
   * original code from tePLSQL @GitHub
   * Receives the name of the object, usually a package,
   * which contains an embedded template and return the template.
   *
   * @param  p_template_name    the name of the template
   * @param  p_object_name      the name of the object (usually the name of the package)   
   * @param  p_object_type      the type of the object (PACKAGE, PROCEDURE, FUNCTION...)
   * @param  p_schema           the schema of the object
   * @return                    the template.
   */
    static FUNCTION include (p_template_name   IN VARCHAR2 DEFAULT NULL
                    , p_object_name     IN VARCHAR2 DEFAULT 'TE_TEMPLATES'                    
                    , p_object_type     IN VARCHAR2 DEFAULT 'PACKAGE'
                    , p_schema          IN VARCHAR2 DEFAULT NULL )
       RETURN CLOB
    AS
       l_result       CLOB;
       l_object_ddl   CLOB;
       l_template     CLOB;
       l_tmp          CLOB;
       i              PLS_INTEGER := 1;
       l_found        PLS_INTEGER := 0;       
       l_object_name     VARCHAR2 (64);
       l_template_name   VARCHAR2 (64);
       l_object_type     VARCHAR2 (64);
       l_schema          VARCHAR2 (64);       
    BEGIN
    
        --Force Defaults
        l_template_name := p_template_name;
        l_object_name := NVL(p_object_name,'TE_TEMPLATES');    
        l_object_type := NVL(p_object_type,'PACKAGE');
        l_schema := p_schema;
        
       --Search for the template in the table TE_TEMPLATES
       IF  l_template_name IS NOT NULL 
       AND l_object_name = 'TE_TEMPLATES'
       THEN
          BEGIN
              null;
              /* disabled.
               SELECT   template
                INTO   l_template
                FROM   te_templates
               WHERE   name = UPPER (l_template_name); */
          EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            l_template := EMPTY_CLOB(); 
          END;
          
           RETURN l_template;
           
       ELSE
          --Search the template in other Oracle Object
          
          --Get package source DDL
          l_object_ddl :=
             DBMS_METADATA.get_ddl (NVL (UPPER (l_object_type), 'PACKAGE'), UPPER (l_object_name), UPPER (l_schema));

          --If p_template_name is null get all templates from the object
          --else get only this template.
          IF l_template_name IS NOT NULL
          THEN
             LOOP
                l_tmp       :=
                   REGEXP_SUBSTR (l_object_ddl
                                , '<%@ template([^%>].*?)%>'
                                , 1
                                , i
                                , 'n');

                l_found     := INSTR (l_tmp, 'name=' || l_template_name);

                EXIT WHEN LENGTH (l_tmp) = 0 OR l_found <> 0;
                i           := i + 1;
             END LOOP;
          ELSE
             l_found     := 0;
          END IF;

          -- i has the occurrence of the substr where the template is
          l_tmp       := NULL;

          LOOP
             --Get Template from the object
             /* conditional compilation disabled.  assume 11g+ (for now)
             $IF DBMS_DB_VERSION.ver_le_10
             $THEN
                l_tmp       :=
                   REGEXP_REPLACE (REGEXP_REPLACE (REGEXP_SUBSTR (l_object_ddl
                                                                , '\$if[[:blank:]]+false[[:blank:]]+\$then' || CHR (10) || '([^\$end].*?)\$end'
                                                                , 1
                                                                , i
                                                                , 'n')
                                                 , '\$if[[:blank:]]+false[[:blank:]]+\$then\s*' || CHR (10)
                                                 , ''
                                                 , 1
                                                 , 1)
                                 , '\$end'
                                 , ''
                                 , 1
                                 , INSTR ('$end', 1, -1));
             $ELSE */
                l_tmp       :=
                   REGEXP_SUBSTR (l_object_ddl
                                , '\$if[[:blank:]]+false[[:blank:]]+\$then\s*' || CHR (10) || '([^\$end].*?)\$end'
                                , 1
                                , i
                                , 'n'
                                , 1);
--             $END
             l_template  := l_template || l_tmp;
             EXIT WHEN LENGTH (l_tmp) = 0 OR l_found <> 0;
             i           := i + 1;
          END LOOP;

          RETURN l_template;
       END IF;
    END include;
    
    constructor function repo_driver_dbobj( p_mount_point in varchar2, p_base_url in varchar2 ) return self as result
    as
      l_parent template_repo_interface_v1;
    begin
      -- how does one call the PARENT's code ???
      l_parent := template_repo_interface_v1( p_mount_point, p_base_url );
      -- self := cast( l_parent as repo_driver_dbobj );

     -- copy over GRAND PAREN values to SELF
      self.repository_guid := l_parent.repository_guid;
      self.mount_point     := l_parent.mount_point;
      -- copy over PARENT values to SELF
      self.guid     := l_parent.guid;
      self.pwd      := l_parent.pwd;
      self.base_url := l_parent.base_url;

      -- translate BASE_URL to custom variables
      self.import_base_url( p_base_url );

      return;
    end;

    overriding member procedure check_file( p_file in varchar2 := null )
    as
      l_object_name varchar2(50);
    begin
      select object_name
        into l_object_name
      from all_objects
      where owner=self.schema_name
        and object_type=self.object_type
        and object_name= p_file;
    exception
      when no_data_found then
        raise template_repo_const.invalid_file;
    end;
    
    overriding member function ls( p_directory in varchar2 := null ) return XMLType
    as
      l_ret xmltype;
    begin
      select xmlelement( "oddgen",
        xmlagg( xmlelement( "file", object_name ) ) )
      into l_ret
      from all_objects
      where owner=self.schema_name
        and object_type=self.object_type
      ;
      
      return l_ret;
    exception
      when no_data_found then
        return XMLType( '<oddgen />' );
    end;

    overriding member function get_code( p_file_name in varchar2 ) return clob
    as
      l_path directory_t;
    begin

      if instr( p_file_name, template_repo_const.snippet_sep ) > 0 or instr( p_file_name, '/' ) > 0
      then
        -- snippet contains prefixing separator
        l_path := directory_t( p_file_name );
        if instr( l_path.snippet, template_repo_const.snippet_sep) = 1
        then
          l_path.snippet := substr(l_path.snippet, 1 + length( template_repo_const.snippet_sep ) );
        end if;

        return self.get_code( l_path.filename, l_path.snippet );  -- should be l_path.snippet
      end if;

      return self.get_code( p_file_name, null);
    end;

    member function get_code( p_file_name in varchar2, p_snippet in varchar2 ) return clob
    as
    begin
      return repo_driver_dbobj.include( p_snippet, p_file_name, self.object_type, self.schema_name);
    end;

    
    member procedure import_base_url( p_base_url in varchar2)
    as
      l_regexp constant varchar2(50) := '^(FUNCTION:|PACKAGE:)?([[:alnum:]_]+)(@.*)?$';
    begin
      if p_base_url is null then
        self.object_type := 'PACKAGE';
        self.schema_name := user;
        self.db_link     := null;
      elsif regexp_like( p_base_url, l_regexp )
      then
        self.object_type := regexp_replace( p_base_url, l_regexp, '\1');
        self.schema_name := regexp_replace( p_base_url, l_regexp, '\2');
        self.db_link     := regexp_replace( p_base_url, l_regexp, '\3');
        
        if self.object_type is null
        then
          self.object_type := 'PACKAGE';
        else
          self.object_type := substr( self.object_type, 1, length( self.object_type ) - 1);
        end if;
        
        if self.object_type not in ( 'PACKAGE', 'FUNCTION' )
        then
          raise template_repo_const.invalid_repository;
        end if;

        if self.schema_name is null
        then
          raise template_repo_const.invalid_repository;
        end if;
        
      else
        raise template_repo_const.invalid_repository; -- todo correct this - should be invalid_parameter
      end if;
      
      return;
    end;

end;
/