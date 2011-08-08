module Pod::To::Text;

sub pod2text($pod) is export {
    my @declarators;
    given $pod {
        when Pod::Heading      { heading2text($pod)             }
        when Pod::Block::Code  { code2text($pod) ~ "\n\n"       }
        when Pod::Block::Named { named2text($pod) ~ "\n"        }
        when Pod::Block::Para  { para2text($pod) ~ "\n\n"       }
        when Pod::Block::Declarator { declarator2text($pod)     }
        when Pod::Item         { item2text($pod) ~ "\n"         }
        when Positional        { $pod.map({pod2text($_)}).join  }
        default                { $pod.Str                       }
    }
}

sub heading2text($pod) {
    given $pod.level {
        when 1  {          pod2text($pod.content)  }
        when 2  { '  '   ~ pod2text($pod.content)  }
        default { '    ' ~ pod2text($pod.content)  }
    }
}

sub code2text($pod) {
    "    " ~ $pod.content.subst(/\n/, "\n    ", :g)
}

sub item2text($pod) {
    ' * ' ~ pod2text($pod.content).chomp.chomp
}

sub named2text($pod) {
    $pod.name eq 'pod' ?? pod2text($pod.content) !! para2text($pod)
}

sub para2text($pod) {
    $pod.content.join("\n")
}

sub declarator2text($pod) {
    next unless $pod.WHEREFORE.WHY;
    do given $pod.WHEREFORE {
        when Method {
            'method'
        }
        when Sub {
            'sub'
        }
        when nqp::p6bool(nqp::istype($_.HOW, Metamodel::ClassHOW)) {
            'class'
        }
        when nqp::p6bool(nqp::istype($_.HOW, Metamodel::ModuleHOW)) {
            'module'
        }
    } ~ ' ' ~ $pod.WHEREFORE.perl ~ ': ' ~ $pod.WHEREFORE.WHY ~ "\n"
}

# vim: ft=perl6