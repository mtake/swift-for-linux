import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.Reader;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.regex.Pattern;
import java.util.Set;
import java.util.TreeMap;


/**
 * Post processor to create a CSV file from profiling information with operf.
 * 
 * Usage: java SwiftOperfProcessor [file1 file2 ...]
 * 
 * Files must be something like "opreport-l-APPLICATION.txt", where APPLICATION is used for the label in the output file.
 * When no files were specified, files with the valid name will be searched from the current working directory.
 * 
 * @author mtake
 */
public class SwiftOperfProcessor {

    static final String file_prefix = "opreport-l-";
    static final String file_suffix = ".txt";
    static final String image_prefix = "lib";
    static final String image_suffix = ".so";

    static final Pattern images_LIBICU = Pattern.compile("libicu.*");
    static final Pattern images_LIBC = Pattern.compile("libc-.*");
    static final Pattern images_LD = Pattern.compile("ld-.*");
    static final Pattern images_LIBFOUNDATION = Pattern.compile("libFoundation.*");
    static final Pattern images_VMLINUX = Pattern.compile("vmlinux-.*");
    static final Pattern images_LIBSWIFTCORE = Pattern.compile("libswiftCore.*");
    //static final Pattern symbols_LIBSWIFTCORE_ATOMIC_RC = Pattern.compile(".*swift_(release|retain).*");
    static final Pattern symbols_LIBSWIFTCORE_ATOMIC_RC = Pattern.compile(".*swift_(release(?!_dealloc).*|retain.*)");
    static final Pattern symbols_LIBSWIFTCORE_NONATOMIC_RC = Pattern.compile(".*swift_nonatomic_(release|retain).*");

    // NOTE image name for application must be "main" when compiled with -Ounchecked -whole-module-optimization
    static final String image_APPLICATION = "main";
    // NOTE * is not allowed for excel sheet name
    static final String image_LIBICU = images_LIBICU.pattern().replaceAll("[-\\.\\*]+", "");
    //static final String image_LIBICU = "libicu";
    // NOTE * is not allowed for excel sheet name
    static final String image_LIBC = images_LIBC.pattern().replaceAll("[-\\.\\*]+", "");
    //static final String image_LIBC = "libc";
    // NOTE * is not allowed for excel sheet name
    static final String image_LD = images_LD.pattern().replaceAll("[-\\.\\*]+", "");
    //static final String image_LD = "ld";
    // NOTE * is not allowed for excel sheet name
    static final String image_LIBFOUNDATION = images_LIBFOUNDATION.pattern().replaceAll("[-\\.\\*]+", "");
    //static final String image_LIBFOUNDATION = "libFoundation";
    // NOTE * is not allowed for excel sheet name
    static final String image_VMLINUX = images_VMLINUX.pattern().replaceAll("[-\\.\\*]+", "");
    //static final String image_VMLINUX = "vmlinux";
    static final String image_OTHERS = "others";
    // NOTE * is not allowed for excel sheet name
    //static final String image_SWIFTCORE_ATOMIC_RC = "libswiftCore(" + symbols_LIBSWIFTCORE_ATOMIC_RC.pattern().replaceAll("[-\\.\\*]+", "") + ")";
    //static final String image_SWIFTCORE_ATOMIC_RC = symbols_LIBSWIFTCORE_ATOMIC_RC.pattern().replaceAll("[-\\.\\*]+", "");
    static final String image_SWIFTCORE_ATOMIC_RC = "libswiftCore(atomicRC)";
    // NOTE * is not allowed for excel sheet name
    //static final String image_SWIFTCORE_NONATOMIC_RC = "libswiftCore(" + symbols_LIBSWIFTCORE_NONATOMIC_RC.pattern().replaceAll("[-\\.\\*]+", "") + ")";
    //static final String image_SWIFTCORE_NONATOMIC_RC = symbols_LIBSWIFTCORE_NONATOMIC_RC.pattern().replaceAll("[-\\.\\*]+", "");
    static final String image_SWIFTCORE_NONATOMIC_RC = "libswiftCore(nonatomicRC)";
    static final String image_SWIFTCORE_OTHERS = "libswiftCore(others)";

    // merged, split and sorted
    static final String[] top_images = {
        image_APPLICATION,
        image_OTHERS,
        image_LIBFOUNDATION,
        image_LD,
        image_VMLINUX,
        image_LIBICU,
        image_LIBC,
        image_SWIFTCORE_OTHERS,
        image_SWIFTCORE_ATOMIC_RC,
        image_SWIFTCORE_NONATOMIC_RC
    };
    static final Set<String> top_images_set = new HashSet<String>();
    static {
        top_images_set.addAll(Arrays.asList(top_images));
    }

    static final TreeMap<String,String> application_to_image = new TreeMap<String,String>();
    static {
        application_to_image.put("ArrayAppendReserved", "ArrayAppend");
        application_to_image.put("ArrayAppendSequence", "ArrayAppend");
        application_to_image.put("ArrayAppendArrayOfInt", "ArrayAppend");
        application_to_image.put("ArrayAppendStrings", "ArrayAppend");
        application_to_image.put("ArrayAppendGenericStructs", "ArrayAppend");
        application_to_image.put("ArrayAppendOptionals", "ArrayAppend");
        application_to_image.put("ArrayAppendLazyMap", "ArrayAppend");
        application_to_image.put("ArrayAppendRepeatCol", "ArrayAppend");
        application_to_image.put("ArrayValueProp", "ArrayLiteral");
        application_to_image.put("ArrayValueProp2", "ArrayLiteral");
        application_to_image.put("ArrayValueProp3", "ArrayLiteral");
        application_to_image.put("ArrayValueProp4", "ArrayLiteral");
        application_to_image.put("Dictionary", "DictTest");
        application_to_image.put("DictionaryOfObjects", "DictTest");
        application_to_image.put("Dictionary2", "DictTest2");
        application_to_image.put("Dictionary2OfObjects", "DictTest2");
        application_to_image.put("Dictionary3", "DictTest3");
        application_to_image.put("Dictionary3OfObjects", "DictTest3");
        application_to_image.put("DictionaryRemoveOfObjects", "DictionaryRemove");
        application_to_image.put("DictionarySwapOfObjects", "DictionarySwap");
        application_to_image.put("HashTest", "Hash");
        application_to_image.put("PopFrontArray", "PopFront");
        application_to_image.put("PopFrontArrayGeneric", "PopFrontGeneric");
        application_to_image.put("PopFrontUnsafePointer", "PopFront");
        application_to_image.put("RGBHistogramOfObjects", "RGBHistogram");
        application_to_image.put("SetExclusiveOr", "SetTests");
        application_to_image.put("SetExclusiveOr_OfObjects", "SetTests");
        application_to_image.put("SetIntersect", "SetTests");
        application_to_image.put("SetIntersect_OfObjects", "SetTests");
        application_to_image.put("SetIsSubsetOf", "SetTests");
        application_to_image.put("SetIsSubsetOf_OfObjects", "SetTests");
        application_to_image.put("SetUnion", "SetTests");
        application_to_image.put("SetUnion_OfObjects", "SetTests");
        application_to_image.put("SortStringsUnicode", "SortStrings");
        application_to_image.put("StringEqualPointerComparison", "StringTests");
        application_to_image.put("StringWithCString", "StringTests");
    }

    static String applicationToImage(String name) {
        String image = application_to_image.get(name);
        if (image == null) image = name;
        return image_prefix + image + image_suffix;
    }

    static String mergeImage(String image) {
        if (images_LIBICU.matcher(image).matches()) {
            return image_LIBICU;
        }
        if (images_LIBC.matcher(image).matches()) {
            return image_LIBC;
        }
        if (images_LD.matcher(image).matches()) {
            return image_LD;
        }
        if (images_LIBFOUNDATION.matcher(image).matches()) {
            return image_LIBFOUNDATION;
        }
        if (images_VMLINUX.matcher(image).matches()) {
            return image_VMLINUX;
        }
        if ("libTestsUtils.so".equals(image)) {
            return image_APPLICATION;
        }
        return image;
    }

    static String splitImage(String image, String symbol) {
        if (!images_LIBSWIFTCORE.matcher(image).matches()) return image;

        if (symbols_LIBSWIFTCORE_ATOMIC_RC.matcher(symbol).matches()) {
            return image_SWIFTCORE_ATOMIC_RC;
        } else if (symbols_LIBSWIFTCORE_NONATOMIC_RC.matcher(symbol).matches()) {
            return image_SWIFTCORE_NONATOMIC_RC;
        } else {
            //System.out.println(symbol);
            return image_SWIFTCORE_OTHERS;
        }
    }


    class Application {

        // percent
        final Map<String,Map<String,Double>> image_to_symbolspercent = new TreeMap<String,Map<String,Double>>();
        final Map<String,Double> image_to_totalpercent = new TreeMap<String,Double>();

        // sample
        final Map<String,Map<String,Long>> image_to_symbolssample = new TreeMap<String,Map<String,Long>>();
        final Map<String,Long> image_to_totalsample = new TreeMap<String,Long>();
        long applicationtotalsample = 0;

        final String name;

        final BufferedReader reader;


        public Application(String name, Reader reader) throws Exception {
            this.name = name;
            this.reader = reader instanceof BufferedReader ? (BufferedReader) reader : new BufferedReader(reader);
        }

        void process() throws Exception {
            String line = null;

            while ((line = reader.readLine()) != null) {

                if (line.length() == 0) continue;

                char c = line.charAt(0);

                if (!Character.isDigit(c)) {
                    //CPU: Intel Sandy Bridge microarchitecture, speed 3500 MHz (estimated)
                    //Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (No unit mask) count 100000
                    //samples  %        image name               symbol name
                    //OUT.println("Skipped: " + line);
                    continue;
                }

                //84214    53.6214  libswiftCore.so          _swift_retain_
                String[] splits = line.split(" +", 4);

                long sample = Long.parseLong(splits[0]);               // 84214
                applicationtotalsample += sample;
                double percent = Double.parseDouble(splits[1]);        // 53.6214
                String image = splits[2];                              // libswiftCore.so
                String symbol = splits[3];                             // _swift_retain_


                // use same image name for all applications
                String application_image = applicationToImage(name);
                if (image.equals(application_image)) {
                    image = image_APPLICATION;
                }

                // merge multiple images into pseudo single image
                image = mergeImage(image);

                // split swift core into multiple pseudo images
                image = splitImage(image, symbol);



                // merge minor images into one
                if (!top_images_set.contains(image)) {
                    image = image_OTHERS;
                }



                // percent
                Map<String,Double> symbol_to_percent = image_to_symbolspercent.get(image);
                if (symbol_to_percent == null) {
                    symbol_to_percent = new TreeMap<String,Double>();
                    image_to_symbolspercent.put(image, symbol_to_percent);
                }
                Double _percent = symbol_to_percent.get(symbol);
                assert _percent == null; // valid if not merged
                double thispercent = percent;
                if (_percent != null) {
                    thispercent += _percent;
                }
                symbol_to_percent.put(symbol, thispercent);
                Double _totalpercent = image_to_totalpercent.get(image);
                double totalpercent = percent;
                if (_totalpercent != null) {
                    totalpercent += _totalpercent;
                }
                image_to_totalpercent.put(image, totalpercent);


                // sample
                Map<String,Long> symbol_to_sample = image_to_symbolssample.get(image);
                if (symbol_to_sample == null) {
                    symbol_to_sample = new TreeMap<String,Long>();
                    image_to_symbolssample.put(image, symbol_to_sample);
                }
                Long _sample = symbol_to_sample.get(symbol);
                assert _sample == null; // valid if not merged
                long thissample = sample;
                if (_sample != null) {
                    thissample += _sample;
                }
                symbol_to_sample.put(symbol, thissample);
                Long _totalsample = image_to_totalsample.get(image);
                long totalsample = sample;
                if (_totalsample != null) {
                    totalsample += _totalsample;
                }
                image_to_totalsample.put(image, totalsample);

                // NOTE for global information
                Long _globaltotalsample = image_to_globaltotalsample.get(image);
                long globaltotalsample = sample;
                if (_globaltotalsample != null) {
                    globaltotalsample += _globaltotalsample;
                }
                image_to_globaltotalsample.put(image, globaltotalsample);
            }

            //debugSummary();

            reader.close();
        }


        void debugSummary() {
            OUT.println("[[" + name + "]]");

            OUT.println("applicationtotalsample=" + applicationtotalsample);

            /*
            OUT.println("<<<image_to_totalpercent>>>");
            printMap(image_to_totalpercent);

            OUT.println("<<<image_to_symbolspercent>>>");
            printMap(image_to_symbolspercent);
            */

            OUT.println("<<<image_to_totalsample>>>");
            printMap(image_to_totalsample);

            OUT.println("<<<image_to_symbolssample>>>");
            printMap(image_to_symbolssample);
        }

        void printSummary() {
            OUT.print(name);

            for (String image : top_images) {
                Long _totalsample = image_to_totalsample.get(image);
                long totalsample = _totalsample != null ? (long) _totalsample : 0;
                OUT.print(","+totalsample);
            }
            // NOTE in case top_images doesn't include image_OTHERS
            if (!top_images_set.contains(image_OTHERS)) {
                Long _totalsample = image_to_totalsample.get(image_OTHERS);
                long totalsample = _totalsample != null ? (long) _totalsample : 0;
                OUT.print(","+totalsample);
            }

            OUT.println();
        }

    }


    final TreeMap<String, Application> name_to_application = new TreeMap<String, Application>();

    // NOTE for global information
    final TreeMap<String, Long> image_to_globaltotalsample = new TreeMap<String, Long>();

    final PrintWriter OUT = new Object() {
            PrintWriter apply() {
                //return new PrintWriter(System.out);
                try {
                    return new PrintWriter(new FileWriter("output.csv"));
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return null;
            }
        }.apply();


    static String fileToName(String filename) {
        int lastIndex = filename.lastIndexOf(file_prefix);
        if (lastIndex < 0 || !filename.endsWith(file_suffix)) {
            return null;
        }
        String name = filename.substring(lastIndex + file_prefix.length(), filename.length() - file_suffix.length());
        return name;
    }

    public void processAll(String[] args) {

        if (args.length >= 1) {
            for (String filename : args) {

                String name = fileToName(filename);
                if (name == null) {
                    //OUT.println("Skipped " + filename);
                    continue;
                }

                //OUT.println(name);
                try {
                    Application application = new Application(name, new FileReader(filename));
                    application.process();
                    name_to_application.put(name, application);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else {
            File dir = new File(".");
            File[] filesList = dir.listFiles();
            for (File file : filesList) {
                if (!file.isFile()) {
                    continue;
                }
                String filename = file.getName();

                String name = fileToName(filename);
                if (name == null) {
                    //OUT.println("Skipped " + filename);
                    continue;
                }

                //OUT.println(name);
                try {
                    Application app = new Application(name, new FileReader(filename));
                    app.process();
                    name_to_application.put(name, app);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

    }


    void printSummary() {
        for (Entry<String,Application> entry : name_to_application.entrySet()) {
            String name = entry.getKey();
            Application app = entry.getValue();
            app.printSummary();
        }

        /*
        // NOTE for global information
        OUT.println("<<<<image_to_globaltotalsample>>>>");
        printMap(image_to_globaltotalsample);
        */
    }


    void printMap(Map map) {
        Iterator<Entry> iter = (Iterator<Entry>) map.entrySet().iterator();
        while (iter.hasNext()) {
            Entry entry = iter.next();
            Object key = entry.getKey();
            Object value = entry.getValue();
            if (value instanceof Map) {
                OUT.println("[" + key + "]");
                printMap((Map) value);
            }
            else {
                //OUT.println(key + " : " + value);
                OUT.println(key + "," + value);
            }
        }
    }


    void begin() {
        OUT.print(","+String.join(",", top_images));
        // NOTE in case top_images doesn't include image_OTHERS
        if (!top_images_set.contains(image_OTHERS)) {
            OUT.print(","+image_OTHERS);
        }
        OUT.println();
    }

    void end() {
        OUT.flush();
        OUT.close();
    }


    public static void main(String[] args) {
        SwiftOperfProcessor processor = new SwiftOperfProcessor();
        processor.begin();
        processor.processAll(args);
        processor.printSummary();
        processor.end();
    }

}
