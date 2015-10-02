# oddgen-templates

oddgen Templates and API





Table of contents
-----------------
 - /public - Public templates to be used by code generators

 - /src - Source code for the API (Types, Tables, and Packages)

 - /APEX - APEX Application for managing acces to multiple repository sources (eg GitHub, files, Schema Packages, etc.)


Intro
-----

Example for retriving a template via PL/SQL
```sql
declare
 -- primary repository is selected
 r      template_repository_obj := template_repository_obj();
 l_code clob;
begin
  l_code := r.get_code( 'somecode' );
end;
/
```

Access to subdirectories is available to repositories that support them. (eg GitHub/WebDAV)
(relative reference is not yet implemented)


File access string format
-------------------------
 - //abcd  - This changes the repository to the "abcd" repository. (ie this is a "mount point"). PWD is /
 - /some/dir/ - all directories have a trailing slash.  Prefix slash indicate "absolute"
 - filename - if you select this, the entire file is returned.
 - filename%snippet - if you select this, only the selected snippet is returned. (Must be supported by template type)
 
Repositories
------------
Multiple Repository types exist.
To be able to use one, you must first "mount" the repository.

To "(un)mount" on, either use the REPOSITORIES_ADMIN package or the APEX Application.
Currently, the first repository (by PK) is the primary repository.
