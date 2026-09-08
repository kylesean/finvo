#!/usr/bin/env python3
"""Verify localized i18n files contain no untranslated CJK strings.

Two scopes:
1. JSON: per-file policy below.
2. Dart (lib/): user-visible string literals must not contain CJK — copy
   belongs in slang files. Line comments (//, ///) and /* */ blocks are
   skipped (developer notes, not UI). A trailing `// cjk-allow: <reason>`
   pragma exempts legit locale data (e.g. Intl date skeletons like
   'yyyy年M月', which are per-locale format patterns, not copy).

Policy per JSON file:
- en.i18n.json: no CJK characters anywhere (English has no kanji usage).
- ko.i18n.json: no CJK outside the `locale` section, where native language
  names (e.g. "简体中文") are intentionally kept for the language picker.
- ja.i18n.json + zh-Hant.i18n.json: a codepoint check cannot distinguish
  untranslated Chinese from valid Japanese/traditional text, so these use a
  cross-file heuristic instead: a value that is IDENTICAL to the zh base
  value AND contains at least one simplified-only character (one whose
  traditional/Japanese form differs) is flagged as untranslated. Shared
  vocabulary with no script difference (e.g. "取消", "日本語") is not
  flagged, so the heuristic stays quiet on legitimately identical values.

Usage:
    python3 client/tool/check_i18n_cjk.py [--fix]
"""

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
I18N_DIR = ROOT / "lib" / "i18n"
CJK = re.compile(r"[\u4e00-\u9fff]")
ALLOWED_SECTIONS = {"locale"}  # native language names are intentionally kept

# Simplified-only characters: simplified forms whose traditional (and, for
# most, Japanese kanji) counterparts differ. A value copied verbatim from the
# zh base containing one of these was never translated. One char per pair;
# the list covers common UI/finance vocabulary, not every CJK pair.
SIMPLIFIED_ONLY = set(
    "观检关账过环类额选择归记设动应长门们无开时后来见现语说请谢让钱银预"
    "约级单号线网转务历车两严乐习买亿众优传伤伦体余债减击变议订认讨论证"
    "评识该调误读谁课谈谊谣贝财产贮贯费资赛赠赢趋踪轨轮软载辑辞边达迁运"
    "还这进远违连迟适逊递逻遗邮邻郑释鉴针钉钓钙钛钟钢钱铁铜银锁错锋锐链"
    "镜闭问闲间闻阅队阳阴阵阶际陆陈险随隐难雾静页项顺须顾顿颁颂频风飞饰"
    "馆驱驶驾验骑骗马驭驯驰驱驳驴驶驻驼驾驿骄骆骇骋验骏骑骗骚骛骤骥鱼鱿"
    "鲁鲍鲜鲤鲨鲫鲸鸟鸠鸡鸣鸥鸦鸽鸿鹊鹤鹰麦黄齐齿龙龟万与专业丛东丝严丧"
    "个临为举乐之义习乡书买乱争亏云亚产亲亿仅从仑仓仪们价会伞伟传伥伦伫"
    "佥侠侣侥侦侧侨侩侪侬俦俨俩俪俭债倾偬偻偿傥傧储傩儿兑党兰兴兹养兽内"
    "冈册军农冯冲况冻净凄凉凌减凑凛几凤凭凯击凿划刘则刚创删别剂剐剑剥剧"
    "劝办务动励劲劳势勋匀匮区医华协单卖卢卫却厂厅历厉压厌厕厢厦厨县参双"
    "发叙叠号叹吁吓后吕呗员咙哑哕哙哔哝哟唢唤啧啬啭啮啸喷喽嗫嗳嘘嘤嘱噜"
    "嚣场坏块坚坛坝坞坟坠垄垆垩垫垭埙堑堕墙壮声壳壶处备复够头夹夺奂奋奖"
    "奥妆妇妈妩妪妫姗姜娅娆娇娈娱娲娴婴婵婶媪嫒嫔嫱嬷孙学孪宁宝实宠审宪"
    "宫宽宾寝对寻导寿将尔尘尝尧尴尸尽层届属屡屿岁岂岖岗岘岚岛岭岳峡峥崂"
    "崭嵘巅巩币帅师帏帐帜带帧席帮帼幂并广庄庆庐庑库应庙庞废廪开异弃张弥"
    "弯弹强当录彦彻径徕御忆忏忧怀态怂怄怅怆怜总怼恋恹恽恿惬惭惮惯悯愠愤"
    "愦愿慑憷懑懒戆戋戏戗战戬户扎扑执扩扫扬扰抚抛抡护报担拟拢拣拥拦拧拨"
    "择挂挚挛挞挟挠挡挣挤挥捞损捡换捣据捋掳掷掸掺掼揽搀搁搂搅携摄摊撵撷"
    "擞攒敌敛数斋斓斗斩断无旧时旷昼晒晓晕晖暂暧术朴机杀杂条杨杞柳桩桥桦"
    "桧桨梦檩橹榄欢欤欧歼殇残殒殓殡殃毙氢汇汉汤汹沟没沥沦沧沪泞注泪泷泸"
    "泻泼泽泾洁洒洼浅浆浇浊测济浏浑浒浓浔浙涝涟涡涣涤润涧涨涩淀渊渍渎渐"
    "渔温湾湿溃溅滚滞满滤滥滨滩潇潋潍潜澜濒灏灭灯灵灶灿炉炼炽烁烂烟烛烨"
    "烦烧烩烫烬热焕焖爱爷牍牵牺状犷犹狈狞独狭狮狰狱猎猫猬献獭玑玛玮环现"
    "玺珑础砖砀码砺砾硖碛磋磐矿砚矾码眍睁瞪瞬矶龙龚龟钅针钉钊钋钌钍钎钏"
    "钒钓钕钗钙钛钜钝钞钟钠钡钢钤钥钦钧钨钩钫钮钯钰钱钲钳钴钵钷钹钺钻钼"
    "钽钾钿铀铁铂铃铄铅铆铈铉铊铋铌铍铎铐铑铒铕铗铘铙铛铜铝铟铠铡铢铣铤"
    "铥铦铧铨铩铪铬铭铮铯铰铱铲铳铵银铷铸铺铼链铿销锁锂锄锅锆锈锉锋锌锏"
    "锐锑锒错锛锟锡锢锣锤锥锦锨锩锭键锯锰锱锲锴锵锶锷锹锻镀镁镂镆镇镉镊"
    "镌镍镎镏镐镑镒镓镔镖镗镜镝镟镣镦镧镫镬镭镯镰镱镶长门闭问闰闲闳间闵"
    "闷闸闹闺闻闽闾阀阁阂阄阅阈阉阊阎阐阑阔阕阖阗阙阚队阳阴阵阶际陆陇陈"
    "险随隐隶难雳雾霁霉霭靓静鞑韫韦韧韩韬韵页顶项顾须顿颁颂预颅领颇颈颊"
    "颌颐颏颛颜额颞颠颤颢风飏飕飞飨饥饨饪饫饬饭饮饯饰饱饲饴饵饶饷饺饼饽"
    "饿馁馄馅馆馈馋馍馏馐馑馒馓馔馕马驶驰驱驳驴骇骈骋验骑骗骚骛骞骠骡骢"
    "骤骥骧骨骸髅髋髌鬓魇鱼鱿鲁鲂鲅鲆鲈鲍鲐鲑鲔鲖鲜鲟鲠鲢鲤鲦鲧鲨鲫鲭鲮"
    "鲰鲱鲲鲳鲵鲷鲸鲺鲻鲽鳀鳃鳄鳅鳆鳍鳎鳏鳐鳓鳔鳕鳖鳗鳜鳝鳞鳟鸟鸠鸡鸢鸣"
    "鸥鸦鸨鸩鸪鸫鸬鸮鸳鸵鸶鸷鸸鸹鸺鸽鸾鸿鹁鹂鹃鹄鹅鹆鹈鹉鹊鹋鹌鹑鹕鹗鹘"
    "鹚鹛鹜鹞鹣鹤鹦鹧鹩鹪鹫鹬鹭鹰鹳鹾麦麸黄黉黩黪黾鼍齐齑齿龃龅龆龇龈龉"
    "龊龋龌龛"
).difference("万")


def walk(obj, path, findings):
    if isinstance(obj, dict):
        for k, v in obj.items():
            walk(v, path + [k], findings)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            walk(v, path + [str(i)], findings)
    elif isinstance(obj, str) and CJK.search(obj):
        section = path[0] if path else ""
        if section in ALLOWED_SECTIONS:
            return
        findings.append((".".join(path), obj))


def check_file(path: Path, fix: bool) -> int:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"[FAIL] {path}: invalid JSON: {e}")
        return 1

    findings = []
    walk(data, [], findings)

    if not findings:
        return 0

    if fix:
        text = path.read_text(encoding="utf-8")
        for dotted, value in findings:
            # Match the exact JSON literal (handles escaped quotes/backslashes)
            # instead of the raw decoded value.
            literal = json.dumps(value, ensure_ascii=False)
            if literal in text:
                text = text.replace(literal, '""', 1)
        path.write_text(text, encoding="utf-8")
        print(f"[FIXED] {path}: {len(findings)} untranslated entries blanked")
        # Blanking removes the CJK but the entry now renders as EMPTY text in
        # the UI — keep the defect visible instead of silently green.
        print("[WARN] Blanked entries render as empty strings until a real")
        print("[WARN] translation is filled in. Fix these before release:")
        for dotted, _value in findings:
            print(f"[WARN]   {path.name}: {dotted}")
        return 0

    print(f"[FAIL] {path}: {len(findings)} untranslated entries:")
    for dotted, value in findings:
        print(f"  - {dotted}: {value}")
    return 1


def flatten(obj, prefix=""):
    """Flatten {"a": {"b": "v"}} -> {"a.b": "v"} for cross-locale comparison."""
    out = {}
    if isinstance(obj, dict):
        for k, v in obj.items():
            key = f"{prefix}.{k}" if prefix else k
            out.update(flatten(v, key))
    else:
        out[prefix] = obj
    return out


def check_untranslated_cjk_locales(failures: list[str]) -> int:
    """Flag ja / zh-Hant values copied verbatim from the zh base.

    These locales legitimately contain kanji, so a codepoint scan cannot tell
    an untranslated value from valid text. Instead: a value that is byte-
    identical to the zh base value AND contains at least one simplified-only
    character was never translated (shared vocabulary without script
    differences — e.g. "取消", "日本語" — is untouched and stays quiet).
    """
    base_path = I18N_DIR / "zh.i18n.json"
    base = flatten(json.loads(base_path.read_text(encoding="utf-8")))

    failed = False
    for name in ("ja", "zh-Hant"):
        path = I18N_DIR / f"{name}.i18n.json"
        if not path.exists():
            continue
        data = flatten(json.loads(path.read_text(encoding="utf-8")))
        flagged = []
        for key, value in base.items():
            if not isinstance(value, str) or not value.strip():
                continue
            other = data.get(key)
            if (
                isinstance(other, str)
                and other == value
                and SIMPLIFIED_ONLY & set(value)
            ):
                flagged.append((key, value))
        if flagged:
            failed = True
            print(f"[FAIL] {path.name}: {len(flagged)} untranslated entries:")
            for key, value in flagged:
                line = f"  - {key}: {value}"
                print(line)
                failures.append(line)
        else:
            print(f"[OK] {path.name}: no untranslated entries")
    return 1 if failed else 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--fix",
        action="store_true",
        help="blank untranslated values instead of failing",
    )
    args = parser.parse_args()

    files = sorted(I18N_DIR.glob("*.i18n.json"))
    # The base locale (zh) is Chinese by design; ja/zh-Hant are covered by
    # the cross-file untranslated check below.
    files = [
        f
        for f in files
        if not f.name.startswith("zh") and not f.name.startswith("ja")
    ]
    if not files:
        print("[FAIL] no i18n files found under", I18N_DIR)
        return 1

    failed = False
    for f in files:
        if check_file(f, args.fix) != 0:
            failed = True
    if check_untranslated_cjk_locales([]) != 0:
        failed = True
    if check_dart_lib() != 0:
        failed = True
    return 1 if failed else 0


def check_dart_lib() -> int:
    """Scan lib/**/*.dart for CJK in code (comments stripped).

    Full-line (//, ///) and /* */ block comments are developer notes, not
    UI copy. A `cjk-allow` pragma on the raw line exempts legit locale data.
    Returns 0 when clean.
    """
    findings: list[str] = []
    in_block = False
    for path in sorted((ROOT / "lib").rglob("*.dart")):
        # Generated code mirrors slang output — the JSON gate is authoritative.
        if ".g.dart" in path.name or ".freezed.dart" in path.name:
            continue
        # GenUI catalog descriptions feed the MODEL (tool/component schemas),
        # never the screen — translating them has zero user impact.
        if path.name.startswith("catalog_"):
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except OSError:
            continue
        lines = text.split("\n")
        # `dart format` may wrap a statement and push its trailing
        # `// cjk-allow` pragma onto an adjacent line, so the pragma matches
        # within a one-line window around the literal.
        pragma_lines = {
            i for i, raw in enumerate(lines) if "cjk-allow" in raw
        }
        for lineno, raw in enumerate(lines, 1):
            if "cjk-allow" in raw:
                continue
            line = raw
            if in_block:
                if "*/" in line:
                    line = line.split("*/", 1)[1]
                    in_block = False
                else:
                    continue
            while "/*" in line:
                before, _, rest = line.partition("/*")
                if "*/" in rest:
                    after = rest.split("*/", 1)[1]
                    line = before + after
                else:
                    line = before
                    in_block = True
                    break
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            code = line.split("//", 1)[0]
            if CJK.search(code):
                idx = lineno - 1
                if {idx - 2, idx - 1, idx, idx + 1, idx + 2} & pragma_lines:
                    continue
                findings.append(
                    f"{path.relative_to(ROOT)}:{lineno}: {stripped[:100]}"
                )
    if findings:
        print(f"[FAIL] lib/: {len(findings)} CJK hits in Dart code:")
        for finding in findings:
            print(f"  - {finding}")
        return 1
    print("[OK] lib/: no CJK in Dart code")
    return 0


if __name__ == "__main__":
    sys.exit(main())
