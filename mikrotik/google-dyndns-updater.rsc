# Google Dynamic DNS update script
# Required policy: read, write, test, policy
# Add this script to scheduler

# Configuration

:local USERNAME "google dynamic domain username";
:local PASSWORD "google dynamic domai password";
:local DOMAINNAME "domaina name";
:local WANIF "interface name";

# Envs

:global NEWIP;
:global CURRENTIP;

:if ([/interface get $WANIF value-name=running]) do={
# Get the current public IP
    :local requestip [tool fetch url="https://ipv4.icanhazip.com/" mode=https check-certificate=no output=user as-value]
    :set NEWIP [:pick ($requestip->"data") 0 ([:len ($requestip->"data")]-1)]
# Check if IP has changed
    :if ($NEWIP != $CURRENTIP) do={
        :log info "GD-DDNS: Public IP changed to $NEWIP, updating"
        :local gdapi [/tool fetch http-method=post mode=https url="https://$USERNAME:$PASSWORD@domains.google.com/nic/update?hostname=$DOMAINNAME&myip=$NEWIP" check-certificate=no output=user as-value];
        :set CURRENTIP $NEWIP
        :log info "GD-DDNS: Host $DOMAINNAME updated with IP $CURRENTIP"
    }  else={
        :log info "GD-DDNS: Previous IP $NEWIP of $DOMAINNAME not changed, quitting"
    }
} else={
    :log info "GD-DDNS: $WANIF is not currently running, quitting"
}

