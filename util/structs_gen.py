import hjson
import string
import argparse

# Bit length of each register
reg_length = 32

# Entry name for the reserved bits
reserved_name = "_reserved"

# Tab definition as 4 blank spaces #
tab_spaces = "  "

# ENUM definitions #
enum_start = "typedef enum {}_enum {{\n"
enum_end = "}} {}_t;\n\n"

# UNION definitions #
union_start = tab_spaces + "union\n" + tab_spaces + "{\n"
union_end = tab_spaces + "}} {};\n\n"

# STRUCT definitions #
struct_typedef_start = (2 * tab_spaces) + "struct \n" + (
            2 * tab_spaces) + "{{\n"  # used to define a new struct and format the name
struct_entry = (3 * tab_spaces) + "{}" + "{}" + ":{}"  # type, name and amount of bits
struct_typedef_end = (2 * tab_spaces) + "} b ;"  # define the end of the new struct definition and the format for the new type-name

# Documentation comments definitions #
line_comment_start = "/*!< "
line_comment_end = "*/"
struct_comment = "Structure used for bit access"
word_comment = "Type used for word access"


def read_json(json_file):
    """
    Opens the json file taken as input and returns its content
    """
    # Open the hjson file #
    f = open(json_file)
    j_data = hjson.load(f)
    f.close()
    return j_data


def write_template(tpl, structs, enums):
    """
    Opens a given template and substitutes the structs and enums fields.
    Returns a string with the content of the updated template
    """

    # To print the final result into the template
    with open(tpl) as t:
        template = string.Template(t.read())

    return template.substitute(structures_definitions=structs, enums_definitions=enums)


def write_output(out_file, out_string):
    """
    Writes the final out_string into the specified out_file
    """

    with open(out_file, "w") as f:
        f.write(out_string)


def generate_enum(enum_field, name):
    """
    Generates an enum with the values specified.
    The enum is generated basing on the 'enum_field' parameter that contains all the values and names
    :param enum_field: list containing, for each entry, the value, the name and the description for each enum field
    :param name: name of the register field associated to the enum
    :return: the string containing the formatted enum
    """
    enum = enum_start.format(name)

    first_entry = True

    for key in enum_field:
        if first_entry:
            enum += tab_spaces + format(key["name"], "<15") + "=" + tab_spaces + key["value"]
            first_entry = False
        else:
            enum += ",\n" + tab_spaces + format(key["name"], "<15") + "=" + tab_spaces + key["value"]

    enum += "\n"
    enum += enum_end.format(name)

    return enum


def count_bits(bits_range):
    """
    Used to determine if the "bits_range" input string contains only a single bit index or a range of bits.
    In the latter case the range is supposed to be identified with the following format "end_bit:start_bit".
    Ex: "7:0" will correspond to 8 bits from 0 to 7.
    It returns the amount of bits specified in the range

    :param bits_range: string containing the nuber of bit (or range or bits) of a specific field
    :return: the amount of bits
    """
    if bits_range.find(":") != -1:
        start_bit = bits_range.split(":")[1]
        end_bit = bits_range.split(":")[0]
        return int(end_bit) - int(start_bit) + 1
    else:
        return 1


def select_type(amount_of_bits):
    """
    Used to select the C type to give to a specific bit field. The type depends on the amount of bits
    that the filed has.

    :param amount_of_bits: amount of bits of the field to which to assign a type
    :return: the string containing the type selected
    """
    if 1 <= amount_of_bits < 9:
        return "uint8_t"
    elif 9 <= amount_of_bits < 17:
        return "uint16_t"
    elif 17 <= amount_of_bits < 33:
        return "uint32_t"
    elif 33 <= amount_of_bits < 65:
        return "uint64_t"


def add_fields(register_json):
    """
    Loops through the fields of the json of a register, passed as parameter.
    Returns the structs and enums entries relative to the register, already
    indented.

    :param register_json: the json-like description of a register
    :return: the strings of the the struct fields, the enum (if present)
    """

    struct_fields = ""
    enum = ""
    bits_counter = 0  # to count the bits used for all the fields of the register

    # loops through the fields of the register
    for field in register_json["fields"]:
        field_bits = count_bits(field["bits"])
        field_type = select_type(field_bits)

        # Check if there is an ENUM, if yes it generates it and set the type of the associated field
        if "enum" in field:
            field_type = "{}_t".format(field["name"])
            enum += generate_enum(field["enum"], field["name"])

        bits_counter += int(field_bits)

        # Handles the case in which the field has no name (it's given the same name as the register)
        if "name" in field:
            field_name = field["name"]
        else:
            field_name = register_json["name"]

        # insert a new struct in the structs string
        struct_fields += struct_entry.format(format(field_type, "<15"), format(field_name, "<20"),
                                                    format(str(field_bits) + ";", "<5"))

        # if there is a description, it adds a comment
        if "desc" in field:
            struct_fields += line_comment_start + format("bit: {}".format(field["bits"]), "<10") + format(
                field["desc"].replace("\n", " "), "<100") + line_comment_end
        struct_fields += "\n"
                    
    # add an entry for the reserved bits (if present)
    if bits_counter < reg_length:
        reserved_bits = reg_length - bits_counter
        reserved_type = select_type(reserved_bits)
        struct_fields += struct_entry.format(format(reserved_type, "<15"), format(reserved_name, "<20"),
                                                   format(str(reserved_bits) + ";", "<5"))
        struct_fields += "\n"

    return struct_fields, enum


def add_registers(peripheral_json):
    """
    Reads the json description of a peripheral and generates structures for every
    register.

    :param peripheral_json: the json-like description of the registers of a peripheral
    :return: the strings containing the indented structs and enums relative to the registers
    """

    reg_struct = ""
    reg_enum = ""

    # loops through the registers of the hjson
    for elem in peripheral_json['registers']:
        if "multireg" in elem:
            elem = elem["multireg"]
        
        if "name" in elem:
            reg_struct += union_start + struct_typedef_start.format(elem["name"])

            # generate the struct entries relative to the fields of the register
            new_field, new_enum = add_fields(elem)
            reg_struct += new_field
            reg_enum += new_enum

            reg_struct += struct_typedef_end
            reg_struct += format(line_comment_start, ">42") + format(struct_comment, "<100") + "*/\n"

            reg_struct += (2 * tab_spaces) + "uint32_t" + " w;"
            reg_struct += format(line_comment_start, ">36") + format(word_comment, "<110") + "*/\n"

            reg_struct += union_end.format(elem["name"])
    
    return reg_struct, reg_enum


# def gen(input_template, input_hjson_file):
# if __name__ == '__main__':
def main():

    parser = argparse.ArgumentParser(prog="Structure generator",
                                     description="Given a template and a json file as input, it generates "
                                                 "suitable structs and enums and prints them into a file, following the "
                                                 "structure provided by the template.")
    parser.add_argument("--template_filename",
                        help="filename of the template for the final file generation")
    parser.add_argument("--json_filename",
                        help="filename of the input json basing on which the structs and enums will begenerated")
    parser.add_argument("--output_filename",
                        help="name of the file in which to write the final formatted template with the structs "
                             "and enums generated")

    args = parser.parse_args()

    input_template = args.template_filename
    input_hjson_file = args.json_filename
    output_filename = args.output_filename

    data = read_json(input_hjson_file)

    # Two strings used to store all the structs and enums #
    structs_definitions = "typedef struct {\n"      # used to store all the struct definitions to write in the template in the end
    enums_definitions = ""                          # used to store all the enums definitions, if present

    # START OF THE GENERATION #

    reg_structs, reg_enums = add_registers(data)
    structs_definitions += reg_structs
    enums_definitions += reg_enums

    structs_definitions += "}} {};".format(data["name"])

    final_output = write_template(input_template, structs_definitions, enums_definitions)
    write_output(output_filename, final_output)


if __name__ == "__main__":
    main()