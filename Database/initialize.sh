#!/bin/bash
#: Your comments here.
set -o errexit
set -o nounset
set -o pipefail

work_dir=$(dirname "$(readlink --canonicalize-existing "${0}" 2> /dev/null)")
readonly conf_file="${work_dir}/script.conf"
readonly error_reading_conf_file=80
readonly error_parsing_options=81
readonly script_name="${0##*/}"
a_option_flag=0
p_option_flag=0
d_option_flag=0
w_option_flag=0

trap clean_up ERR EXIT SIGINT SIGTERM

usage() {
    cat <<USAGE_TEXT
Usage: ${script_name} [-h | --help] [-a <ARG>] [--abc <ARG>] [-f | --flag]

DESCRIPTION
    Create database from SQL scripts. Example usage:

      ./initialize.sh -a DATABASE_HOST -p DATABASE_PORT -d DATABASE_NAME -w POSTGRES_PASSWORD

    OPTIONS:

    -h, --help
        Print this help and exit.

    -a
        Database host.

    -p
        Database port.

    -d
        Database name.

    -w
        Database postgres user password.

USAGE_TEXT
}

clean_up() {
    trap - ERR EXIT SIGINT SIGTERM
    # Remove temporary files/directories, log files or rollback changes.
}

die() {
    local -r msg="${1}"
    local -r code="${2:-90}"
    echo "${msg}" >&2
    exit "${code}"
}

if [[ ! -f "${conf_file}" ]]; then
    die "error reading configuration file: ${conf_file}" "${error_reading_conf_file}"
fi

# shellcheck source=script.conf
. "${conf_file}"

parse_user_options() {
    local -r args=("${@}")
    local opts

    # The following code works perfectly for
    opts=$(getopt --options a:,p:,d:,w:,h --long help -- "${args[@]}" 2> /dev/null) || {
        usage
        die "error: parsing options" "${error_parsing_options}"
    }

    eval set -- "${opts}"

    while true; do
    case "${1}" in

        --abc)
            abc_option_flag=1
            readonly abc_arg="${2}"
            shift
            shift
            ;;

        -a)
            a_option_flag=1
            readonly a_arg="${2}"
            shift
            shift
            ;;

        -p)
            p_option_flag=1
            readonly p_arg="${2}"
            shift
            shift
            ;;

        -d)
            d_option_flag=1
            readonly d_arg="${2}"
            shift
            shift
            ;;

        -w)
            w_option_flag=1
            readonly w_arg="${2}"
            shift
            shift
            ;;

        --help|-h)
            usage

            exit 0
            shift
            ;;

        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
    done
}

parse_user_options "${@}"

if [ $# -eq 0 ]
  then
    usage
    exit 1
fi

# check required params and arguments
[[ -z "${a_arg:-}" ]] && die "Missing required parameter: -a host"
[[ -z "${p_arg:-}" ]] && die "Missing required parameter: -p port"
[[ -z "${d_arg:-}" ]] && die "Missing required parameter: -d database_name"
[[ -z "${w_arg:-}" ]] && die "Missing required parameter: -w postgres_password"

docker run -it --rm --network=host -v "${PWD}":/scripts -e PGPASSWORD="${w_arg}" postgres /bin/sh /scripts/run-sql.sh "${d_arg}" "${a_arg}" "${p_arg}"
docker run --rm --network=host -v ${localPath}:/liquibase/changelog -w /liquibase/changelog liquibase/liquibase liquibase --changeLogFile=dbchangelog.xml
--url=jdbc:postgresql://${dbHost}:${dbPort}/${dbName} --username postgres --password ${pgPass} --log-level=info update
exit 0
