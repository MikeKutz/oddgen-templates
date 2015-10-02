create or replace
type template_repo_interface_core as object (
  /**
    This is the top most level UDT for Template Repository Interface/Implementations.
    Its sole purpose is to make migraction from Interface v1 to v2 to v3 to ... easy.
    
    NOT FINAL
    NOT INSTANTIABLE
    @headcom
  */
  repository_guid varchar2(50),
  mount_point     varchar2(4000)
)
not FINAL
not INSTANTIABLE
;
/