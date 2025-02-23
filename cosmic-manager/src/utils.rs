// SPDX-License-Identifier: GPL-3.0-only

pub fn escape_string(input: &str) -> String {
    let mut output = String::with_capacity(input.len());

    for c in input.chars() {
        let escaped = match c {
            // Common escape sequences
            '"' => "\\\"",  // double quote
            '\\' => "\\\\", // backslash
            '\n' => "\\n",  // newline
            '\r' => "\\r",  // carriage return
            '\t' => "\\t",  // tab
            '\'' => "\\'",  // single quote
            '\0' => "\\0",  // null

            // Less common escape sequences
            '\x07' => "\\a", // bell (alert)
            '\x08' => "\\b", // backspace
            '\x0C' => "\\f", // form feed
            '\x0B' => "\\v", // vertical tab

            // Control characters (0x00-0x1F, except those already handled)
            c if c.is_control() && (c as u32) < 0x20 => {
                output.push_str(&format!("\\x{:02x}", c as u32));
                continue;
            }

            // Unicode characters above ASCII
            c if (c as u32) > 0x7F => {
                if (c as u32) <= 0xFFFF {
                    output.push_str(&format!("\\u{:04x}", c as u32));
                } else {
                    output.push_str(&format!("\\U{:08x}", c as u32));
                }
                continue;
            }

            // Printable ASCII characters (don't need escaping)
            _ => {
                output.push(c);
                continue;
            }
        };

        output.push_str(escaped);
    }

    output
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_escape_sequences() {
        let test_cases = [
            // Basic escapes
            ("Hello \"World\"", "Hello \\\"World\\\""),
            ("Path\\to\\file", "Path\\\\to\\\\file"),
            ("Line1\nLine2", "Line1\\nLine2"),
            ("Tab\there", "Tab\\there"),
            ("Return\rhere", "Return\\rhere"),
            ("Single'quote", "Single\\'quote"),
            // Control characters
            ("\x07Bell", "\\aBell"),
            ("Back\x08space", "Back\\bspace"),
            ("Form\x0Cfeed", "Form\\ffeed"),
            ("Vert\x0Btab", "Vert\\vtab"),
            // Null character
            ("Null\0char", "Null\\0char"),
            // Unicode examples
            ("Hello 🦀", "Hello \\U0001f980"), // Rust crab emoji
            ("café", "caf\\u00e9"),            // é character
        ];

        for (input, expected) in test_cases {
            assert_eq!(escape_string(input), expected, "Failed on input: {}", input);
        }
    }
}
