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

typedef int voice_rate_t;

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
            croak ("failed to stop messages");
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
            croak ("failed to stop messages");
        }

int
spd_cancel (connection)
        SPDConnection *connection
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to cancel messages");
        }

int
spd_cancel_all (connection)
        SPDConnection *connection
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to cancel messages");
        }

int
spd_cancel_uid (connection, target_uid)
        SPDConnection *connection
        int target_uid
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to cancel messages");
        }

int
spd_pause (connection)
        SPDConnection *connection
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to pause messages");
        }

int
spd_pause_all (connection)
        SPDConnection *connection
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to pause messages");
        }

int
spd_pause_uid (connection, target_uid)
        SPDConnection *connection
        int target_uid
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to pause messages");
        }

int
spd_resume (connection)
        SPDConnection *connection
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to resume messages");
        }

int
spd_resume_all (connection)
        SPDConnection *connection
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to resume messages");
        }

int
spd_resume_uid (connection, target_uid)
        SPDConnection *connection
        int target_uid
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to resume messages");
        }

int
spd_char (connection, character, priority=SPD_TEXT)
        SPDConnection *connection
        const char *character
        SPDPriority priority
    C_ARGS:
        connection, priority, character
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to say character");
        }

int
spd_key (connection, key_name, priority=SPD_TEXT)
        SPDConnection *connection
        const char *key_name
        SPDPriority priority
    C_ARGS:
        connection, priority, key_name
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to say key");
        }

int
spd_sound_icon (connection, icon_name, priority=SPD_TEXT)
        SPDConnection *connection
        const char *icon_name
        SPDPriority priority
    C_ARGS:
        connection, priority, icon_name
    POSTCALL:
        if (RETVAL < 0) {
            croak ("failed to say sound icon");
        }

int
spd_set_data_mode (connection, mode)
		SPDConnection *connection
		SPDDataMode mode
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set data mode");
		}

int
spd_set_language (connection, language)
		SPDConnection *connection
		const char *language
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set language");
		}

int
spd_set_language_all (connection, language)
		SPDConnection *connection
		const char *language
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set language");
		}

int
spd_set_language_uid (connection, language, uid)
		SPDConnection *connection
		const char *language
		unsigned int uid
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set language");
		}

int
spd_set_output_module (connection, output_module)
		SPDConnection *connection
		const char *output_module
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set output module");
		}

int
spd_set_output_module_all (connection, output_module)
		SPDConnection *connection
		const char *output_module
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set output module");
		}

int
spd_set_output_module_uid (connection, output_module, uid)
		SPDConnection *connection
		const char *output_module
		unsigned int uid
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set output module");
		}

int
spd_set_punctuation (connection, type)
		SPDConnection *connection
		SPDPunctuation type
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set puctuation");
		}

int
spd_set_punctuation_all (connection, type)
		SPDConnection *connection
		SPDPunctuation type
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set puctuation");
		}

int
spd_set_punctuation_uid (connection, type, uid)
		SPDConnection *connection
		SPDPunctuation type
		unsigned int uid
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set puctuation");
		}

int
spd_set_spelling (connection, type)
		SPDConnection *connection
		SPDSpelling type
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set spelling");
		}

int
spd_set_spelling_all (connection, type)
		SPDConnection *connection
		SPDSpelling type
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set spelling");
		}

int
spd_set_spelling_uid (connection, type, uid)
		SPDConnection *connection
		SPDSpelling type
		unsigned int uid
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set spelling");
		}

int
spd_set_voice_type (connection, voice)
		SPDConnection *connection
		SPDVoiceType voice
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice type");
		}

int
spd_set_voice_type_all (connection, voice)
		SPDConnection *connection
		SPDVoiceType voice
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice type");
		}

int
spd_set_voice_type_uid (connection, voice, uid)
		SPDConnection *connection
		SPDVoiceType voice
		unsigned int uid
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice type");
		}

int
spd_set_synthesis_voice (connection, voice_name)
		SPDConnection *connection
		const char *voice_name
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice");
		}

int
spd_set_synthesis_voice_all (connection, voice_name)
		SPDConnection *connection
		const char *voice_name
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice");
		}

int
spd_set_synthesis_voice_uid (connection, voice_name, uid)
		SPDConnection *connection
		const char *voice_name
		unsigned int uid
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice");
		}

int
spd_set_voice_rate (connection, rate)
		SPDConnection *connection
		voice_rate_t rate
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice rate");
		}

int
spd_set_voice_rate_all (connection, rate)
		SPDConnection *connection
		voice_rate_t rate
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice rate");
		}

int
spd_set_voice_rate_uid (connection, rate, uid)
		SPDConnection *connection
		voice_rate_t rate
		unsigned int uid
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice rate");
		}

int
spd_set_voice_pitch (connection, pitch)
		SPDConnection *connection
		voice_rate_t pitch
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice pitch");
		}

int
spd_set_voice_pitch_all (connection, pitch)
		SPDConnection *connection
		voice_rate_t pitch
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice pitch");
		}

int
spd_set_voice_pitch_uid (connection, pitch, uid)
		SPDConnection *connection
		voice_rate_t pitch
		unsigned int uid
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set voice pitch");
		}

int
spd_set_volume (connection, volume)
		SPDConnection *connection
		voice_rate_t volume
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set volume");
		}

int
spd_set_volume_all (connection, volume)
		SPDConnection *connection
		voice_rate_t volume
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set volume");
		}

int
spd_set_volume_uid (connection, volume, uid)
		SPDConnection *connection
		voice_rate_t volume
		unsigned int uid
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set volume");
		}

int
spd_set_capital_letters (connection, type)
		SPDConnection *connection
		SPDCapitalLetters type
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set capital letters");
		}

int
spd_set_capital_letters_all (connection, type)
		SPDConnection *connection
		SPDCapitalLetters type
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set capital letters");
		}

int
spd_set_capital_letters_uid (connection, type, uid)
		SPDConnection *connection
		SPDCapitalLetters type
		unsigned int uid
	POSTCALL:
		if (RETVAL < 0) {
			croak ("failed to set capital letters");
		}
