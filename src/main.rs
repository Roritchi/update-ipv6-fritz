use std::net::Ipv6Addr;
use std::env;

fn combine_ipv6(prefix: &str, suffix: &str, prefix_length: u8) -> String {
    // Präfix in ein 128-Bit-Array konvertieren
    let prefix_addr: Ipv6Addr = prefix.parse().expect("Ungültiger Präfix");
    let mut prefix_bits = prefix_addr.octets();

    // Suffix in ein 128-Bit-Array konvertieren
    let suffix_addr: Ipv6Addr = suffix.parse().expect("Ungültiger Suffix");
    let suffix_bits = suffix_addr.octets();

    // Überschreibe die Bits nach dem Präfix
    let byte_offset = (prefix_length / 8) as usize;
    let bit_offset = (prefix_length % 8) as usize;

    if bit_offset > 0 {
        // Überschreibe verbleibende Bits im aktuellen Byte
        let mask = 0xFF << (8 - bit_offset);
        prefix_bits[byte_offset] = (prefix_bits[byte_offset] & mask) | (suffix_bits[byte_offset] & !mask);
    }

    // Kopiere die restlichen Bytes vom Suffix
    for i in (byte_offset + 1)..16 {
        prefix_bits[i] = suffix_bits[i];
    }

    // Neues IPv6-Objekt aus den Bits erstellen
    let new_addr = Ipv6Addr::from(prefix_bits);
    new_addr.to_string()
}

fn main() {
    let mut prefix = "test-2a00:1e:8180:a700::";
    let mut suffix = "::a701:be24:11ff:feea:72c5";
    let prefix_length = 56;

    // Alle Argumente (einschließlich des Programmnamen)
    let args: Vec<String> = env::args().collect();

    // Wenn Argumente übergeben wurden, drucke sie
    if args.len() > 1 {
        eprintln!("Argumente:");
        for (i, arg) in args.iter().enumerate().skip(1) {
            eprintln!("Argument {}: {}", i, arg);
            if i == 1 {
                prefix = arg;
            } else if i == 2 {
                suffix = arg;
            }
        }
    } else {
        eprintln!("Keine Argumente übergeben.");
    }

    eprintln!("Prefix: {}/{}", prefix, prefix_length);
    eprintln!("Suffix: {}", suffix);

    // Berechnung der neuen IPv6-Adresse
    let new_ipv6 = combine_ipv6(prefix, suffix, prefix_length + 1);
    println!("{}", new_ipv6);
}

