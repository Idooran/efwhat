
for i in "$@"
do
case $i in
    -ip=*|--ip=*)
    IP="${i#*=}"
    shift # past argument=value
    ;;
    -h=*|--hostname=*)
    HOST="${i#*=}"
    shift # past argument=value
    ;;
    *)
        # unknown option
    ;;
esac
done

nsupdate
prereq HOST
update add HOST 300 A IP