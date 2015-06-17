This is a simple service.

It receives a request to compute a fixity for a file to which it has local access, described as a relative path
from a fixed route. The remote requester presumably also has access to that file and can compute the relative path,
though the absolute path may differ. The advantages of having this server compute it instead of the remote server
are a) the work is offloaded and b) this server is ideally has better access to the content. I.e. in our case the
remote server has an NFS mount and this server ideally has a direct GPFS mount. Also, this should be easily
modifiable also to compute fixities of resources specified by urls.

Configuration
=============

config/medusa_fixity_server.yaml contains the amqp configuration and information about the root of the files. See
the template for available parameters.

Running
=======

The medusa_fixity.sh script can be used to start and stop the server. There is also a toggle-halt
command that will let the server finish the request it is working on and then halt (or if used again go cancel this
behavior). This works by sending USR2 to the server, so you can do that manually as well.

Requests
========

A request is a JSON object with three fields:

- action: The action being requested. Currently only 'file_fixity' is supported.
- parameters: Parameters needed for the action.
- pass_through: A JSON object that the server will pass back to the client with its response. The intended use
 is for the client to be able to know what is being responded to.

A response is a JSON object with fields:

- pass_through: Whatever the client originally passed in this field, or nil if absent.
- status: Either 'success' or 'failure'.
- error_message: If the status is failure then this may be returned to give information.
- action: The originally requested action
- parameters: A JSON object with parameters appropriate to the request. For the fixity request would have the hash type(s) and value(s).

Note that for certain errors (e.g. if the request isn't parseable as JSON) it may not be possible to return some
of these things.

file_fixity action:

- Incoming parameters:

  - path - this is the file path relative to the cfs root.
  - algorithms - an array of names of fixity algorithms to be computed. Possible values include "md5" and "sha1".
            Unknown values will be ignored.
	    If there are no valid values then the md5 only will be computed and returned.

And: 

- Outgoing parameters:

  - found - a boolean telling if the file was found. If not then checksums will be empty, but the server interaction is
  still considered to be a success.
  - checksums - an object with keys the hash types and values the computed checksums
  