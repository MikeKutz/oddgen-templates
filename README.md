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

Access to subdirectories is available to repositories that support them. (eg local files/DBFS/GitHub/WebDAV)
The goal is to allow templates to include other templates via relative reference.

File access string format
-------------------------
Sample template name:
```sql
  code_to_retrieve := '//abcd/some/dir/filename%snippet';
```
Definition:
 - //abcd  - This changes the repository to the "abcd" repository. (ie this is a "mount point"). Current Working Directory defaults to "/"
 - /some/dir/ - all directories have a trailing slash.  Prefix slash indicate "absolute".  This must be supported by the Repository Type
 - filename - if you select this, the entire file is returned.
 - filename%snippet - if you select this, only the selected snippet is returned.  This must be supported by the Repository Type.

Example parameters for get_code():
- '//reponame/path/templateX' - returns the code from template.  Cross repository retrieval is currently not allowed. (one developer's "//repo1" could be another developer's "//repo2")
- '/absolute/path/template' - returns the code from template "template" found in the directory "/absolute/path"- 'subdir/othertemplate' - This is a relative reference.  It returns the code from template "otherTemplate" found in sub-directory 'subdir' of the current working directory. (from UNIX, current working directory is PWD)
- '%snippetPart2' - returns the code snippet "snippetPart2" from current the current template.  This allows one template to hold all components in a single file including, but not limited to, specification, body, anonymous block, and optional code.

Not all repository types allow subdirectories.
 

Repositories
------------
Multiple Repository types exist.  To be able to use a Repository, you must first "mount" the repository.

"mounting" a Repository means you are recording a mount point ( //mnt_point ), a "driver" (eg dbobj ), and parameters to be used by the "driver" (eg "PROCEDURES:SCOTT@remote" ) in the table "TEMPLATE_REPOSITORIES".

To "mount"/"unmount" a repository, either use the REPOSITORIES_ADMIN package or the APEX Application.  By default, the first repository (by PK) is the primary repository.

The architecture of the repository service is this:

<img src="https://raw.github.com/MikeKutz/oddgen-templates/master/template_repository_arch.png" align="center" />

Repository Types
----------------
See the individual driver's README (or PL/DOC) for more information regarding the "parameters" used for instantiating a driver.

- dbobj - templates are stored as Database Objects.
- tetemplate - templates are stored in the table "TE_TEMPLATES" (from tePLSQL project)
- dbfs - templates are stored in a table that contains a column for "directory".  In oracle, this would be a "Database File System".  (not yet implemented)
- cache - uses a session level temporary table to store templates.  This allows UI to copy templates from one or more template repositories in to a single repository that is accessible by the code generator.
- Git - uses a Git repository as the source including GitHub.

Only "dbojb" has been implemented.  Table based template repositories (tetemplate,dbfs,cache) share a lot of "common code".  Enhanements in this area are expected.

Development for Git is on hold.  This driver needs to be able to "cache" results to limit HTTP/WebDAV calls to remote repositories (eg GitHub).

Template Repository Object
--------------------------
This is the Application Program Interface for template repositories that have been defined and "mounted".  (ie exists in the table TEMPLATE_REPOSITORIES)

There are two methods for instantiating the object.
```sql
-- method 1
handle_1 := new_object();
handle_1.cd( template_name );

-- method2
handle_2 := new_object( template_name );

-- all attributes in "handle_1" are identical to "handle_2".
```

The "template_repository_obj" maintains information on the Current Working Directory.  All commands can include the filename and filename%snippetName.  "filename" is expected as part of the CD command to ensure that templates work corretly when they "include" tempate code based on a relative snippet name (eg "<%@ include( '%body' ) %>" )

Expected workflow for code generators:
```sql
declare
  r template_repository_obj := template_repository_obj();
begin
 -- note - this is pseudo code, not working code
 
 -- to ensure relative "includes" work,
 -- You mus set the current working directory.
 r.cd( template_name_sent_from_ui );
 -- generator specific code

   -- begin of "include"
    r.cd( included_filename ); -- set current working directory incase sub-includes are relative
    -- generator specific code
   -- end of "include"

 -- reset current working directory
 r.cd( template_name_sent_from_ui );
end;
```
