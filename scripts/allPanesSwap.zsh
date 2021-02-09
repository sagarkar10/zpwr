#!/usr/bin/env zsh
#{{{                    MARK:Header
#**************************************************************
##### Author: MenkeTechnologies
##### GitHub: https://github.com/MenkeTechnologies
##### Date: Sun Feb  7 21:47:47 EST 2021
##### Purpose: bash script to
##### Notes:
#}}}***********************************************************

exec 2>> "$ZPWR_LOGFILE"
printf "" > $ZPWR_TEMPFILE
declare -a ZPWR_PANES
declare -A ZPWR_PANE_INFO
local line out cnt id winw winh pw ph pl pt h w t l o row col win ary


if ! zmodload zsh/curses; then
    echo "Could NOT load zsh/curses" >&2
    #exit 1
fi

if [[ -z "$2" ]]; then
    echo "usage: allPanesSwap.zsh <win_id> <single/multi>" >&2
    exit 1
fi

win=stdscr

#zcurses addwin $win $LINES $COLUMNS 0 0 

while read id winw winh pw ph pl pr pt; do
    id=${id#%}
    ZPWR_PANES+=(${id})
    ZPWR_PANE_INFO[${id}.w]="$pw"
    ZPWR_PANE_INFO[${id}.h]="$ph"
    ZPWR_PANE_INFO[${id}.t]="$pt"
    ZPWR_PANE_INFO[${id}.l]="$pl"
    ZPWR_PANE_INFO[${id}.r]="$pr"
    ZPWR_PANE_INFO[${id}.o]="$(tmux capture-pane -p -t "%$id")"
done < \
<(tmux lsp -t "$1" -F '#{pane_id} #{window_width} #{window_height} #{pane_width} #{pane_height} #{pane_left} #{pane_right} #{pane_top} ')

#tmux wait-for -U fingerl1

zcurses init
zcurses clear $win

for id in ${ZPWR_PANES[@]};do
    cnt=0
    h=$ZPWR_PANE_INFO[$id.h]
    w=$ZPWR_PANE_INFO[$id.w]
    t=$ZPWR_PANE_INFO[$id.t]
    l=$ZPWR_PANE_INFO[$id.l]
    r=$ZPWR_PANE_INFO[$id.r]
    o=$ZPWR_PANE_INFO[$id.o]
    o="$o."
    ary=("${(@f)${o}}")


    #say zcurses move $win $t $l
    #say zcurses string $win "$o"
    #$id
    case $id in
        *)
            for line in "${ary[@]}"; do
                zcurses move $win $((t + cnt)) $l
                zcurses string $win $line
                ((++cnt))
            done

            ;;
    esac
    #zcurses string $win "$id"

    #for row in {0..$w}; do
        #for col in {0..$((h-1))}; do
            #out[$cnt]=$o[$((row + col))]
            #((++cnt))
        #done
        #((cnt+=$w))

    #done
done

zcurses refresh $win

#echo zcurses delwin $win
if [[ $2 == single ]]; then
    tmux capture-pane -J -p | thumbs -t "$ZPWR_TEMPFILE"
else
    tmux capture-pane -J -p | thumbs -m -t "$ZPWR_TEMPFILE"
fi

out="${(j. .)${(f)$(<$ZPWR_TEMPFILE)}}"
tmux set-buffer "$out"
print -rn -- "$out" | ${=ZPWR_COPY_CMD}

zcurses end

if [[ -z $out ]]; then
    echo empty > "$ZPWR_TEMPFIFO"
else
    echo full > "$ZPWR_TEMPFIFO"
fi
