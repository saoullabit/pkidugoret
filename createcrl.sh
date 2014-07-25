#! /bin/sh

createcrl() {
  TEMP=`getopt -o c:d:lh --long ca:,days:,link,help -n 'createcrl.sh' -- "$@"`
  DAYS=30
  LINK=0

  eval set -- "$TEMP"
  while true; do
    case "$1" in
      -c|--ca) CA=$2; shift 2;;
      -d|--days) DAYS=$2; shift 2;;
      -l|--link) LINK=1; shift;;
      -h|--help) echo "Options:"
		 echo "  -c|--ca <ca>"
		 echo " (-d|--days <days>)        # default 30"
		 echo " (-l|--link)"
		 shift
		 exit 1
		 ;;
      --) shift; break;;
      *) echo "internal error"; exit 1;;
    esac
  done

  if [ -z "$CA" ]; then
    echo "Il faut l'identifiant de l'AC"
    exit 1
  fi

  echo "====="
  echo "Création de la CRL de l'AC $CA, valide pour $DAYS jours"
  CRLNUMBER=`cat database/$CA/crlnumber`
  openssl ca -utf8 -config conf/$CA.cnf -crldays $DAYS -gencrl -out database/$CA/crl/$CRLNUMBER.pem
  echo "Mise à jour du store" && cp database/$CA/crl/$CRLNUMBER.pem store/$CA.crl && if [ $LINK -eq 1 ]; then cd store && ./hashit.sh $CA.crl; fi
  echo "====="
}

createcrl "$@"
