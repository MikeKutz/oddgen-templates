create or replace
type body directory_t
as
  
  constructor function directory_t( p_fqp in varchar2 )
     return self as result
  as
    l_regexp varchar2(200);
  begin
    -- TODO - move to static function
    l_regexp := template_repo_const.regexp_full;
    
    -- clear self;
    SELF := directory_t( null, null, null, null );
    
    if p_fqp is null then
      SELF.full_directory := '/';
    elsif p_fqp = '/' then
      SELF.full_directory := '/';
    elsif regexp_like( p_fqp, l_regexp ) then
      -- extract out values
      SELF.repository     := regexp_replace( p_fqp, l_regexp, '\1' );
      SELF.full_directory := regexp_replace( p_fqp, l_regexp, '\2' );
      -- note - '\3' is the last directory name
      SELF.filename       := regexp_replace( p_fqp, l_regexp, '\4' );
      SELF.snippet        := regexp_replace( p_fqp, l_regexp, '\5' );
      
      -- adjust repository
      if self.repository like '%/'
      then
        self.repository := rtrim( self.repository, '/' );
      end if;

      -- adjust full_directory due to regexp greed
      if self.repository is not null and self.full_directory not like '/%'
      then
        self.full_directory := '/' || self.full_directory;
      end if;
      
      -- adjust full_directory for relative
      if self.full_directory not like '/%'
      then
        -- assume PWD contains prefix and suffix slash
        self.full_directory := '${PWD}' || self.full_directory;
      end if;
      
    else
      raise template_repo_const.invalid_parameter;
    end if;
    return;
  end;
end;
/
