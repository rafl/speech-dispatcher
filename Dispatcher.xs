#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "ppport.h"

#include <libspeechd.h>

STATIC SV *
new_sv_from_ptr (void *ptr, const char *class)
{
    SV *obj, *sv;
    HV *stash;

    obj = (SV *)newHV ();
    sv_magic (obj, 0, PERL_MAGIC_ext, (const char *)ptr, 0);
    sv = newRV_noinc (obj);
    stash = gv_stashpv (class, 0);
    sv_bless (sv, stash);

    return sv;
}

STATIC void *
ptr_from_sv (SV *sv, const char *class)
{
    MAGIC *mg;

    if (!sv || !SvOK (sv) || !SvROK (sv)) {
        croak ("scalar is not a reference");
    }

    if (!sv_derived_from (sv, class)) {
        croak ("object is not a %s", class);
    }

    if (!(mg = mg_find (SvRV (sv), PERL_MAGIC_ext))) {
        croak ("object doesn't have any magic attached to it");
    }

    return (void *)mg->mg_ptr;
}

MODULE = Speech::Dispatcher  PACKAGE = Speech::Dispatcher  PREFIX = spd_

PROTOTYPES: DISABLED

SPDConnection *
spd_open (class, client_name, connection_name, user_name, mode=SPD_MODE_SINGLE)
        const char *client_name
        const char *connection_name
        const char *user_name
        SPDConnectionMode mode
    C_ARGS:
        client_name, connection_name, user_name, mode
    POSTCALL:
        if (!RETVAL) {
            croak ("failed to create connection");
        }

void
DESTROY (connection)
        SPDConnection *connection
    CODE:
        spd_close (connection);

int
spd_say (connection, text, priority=SPD_TEXT)
        SPDConnection *connection
        const char *text
        SPDPriority priority
    C_ARGS:
        connection, priority, text
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to say text");
        }

int
spd_stop (connection)
        SPDConnection *connection
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to stop message");
        }

int
spd_stop_all (connection)
        SPDConnection *connection
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to stop messages");
        }

int
spd_stop_uid (connection, target_uid)
        SPDConnection *connection
        int target_uid
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to stop message");
        }
